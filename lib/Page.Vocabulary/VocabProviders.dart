import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../IO/ISerializer.dart';
import '../Data/Item.dart';
import '../Library/Result.dart';
import '../Data/SourceError.dart';
import '../Page.Sources/SourcesProviders.dart';
import 'VocabModel.dart';

typedef ModelOrError = Result<VocabModel, SourceError>;

final vocabModelProvider = FutureProvider<ModelOrError>((ref) async {
  final sourceName = ref.watch(vocabularyNameProvider);
  return await _getVocabModel(sourceName);
});

final vocabProvider = ChangeNotifierProvider<VocabModel>((ref) {
  var model = ref.watch(vocabModelProvider).value;
  return model!.value!;
});

Future<ModelOrError> _getVocabModel(String sourceName) async {
  var sheets = ["A0", "A1", "A2", "B1"];
  var items = GetIt.I<ISource>().loadVocabulary(sourceName).toList();
  var ind = sheets.indexOf(sourceName);

  for (var i = 0; i < ind; i++) {
    var prev = GetIt.I<ISource>().loadVocabulary(sheets[i]).toList();
    items.addAll(prev);
  }

  final err = SourceError.any(sourceName, items);
  if (err != null) return ModelOrError.error(err);

  addSynonyms(items);
  addSameRoot(items);

  final serializer = GetIt.I<ISerializer>();
  final model = VocabModel(sourceName, items, serializer);
  return ModelOrError.value(model);
}
