import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../Constants.dart';
import '../IO/ISerializer.dart';
import '../Data/Item.dart';
import '../Library/Result.dart';
import '../Data/SourceError.dart';
import '../Page.Sources/SourcesProviders.dart';
import 'VocabModel.dart';

typedef ModelOrError = Result<VocabModel, SourceError>;

final fileResultProvider = FutureProvider<ModelOrError>((ref) async {
  final sourceName = ref.watch(vocabularyNameProvider);
  return await _getVocabModel(sourceName);
});

final vocabProvider = ChangeNotifierProvider<VocabModel>((ref) {
  var model = ref.watch(fileResultProvider).value;
  return model!.value!;
});

Future<ModelOrError> _getVocabModel(String sourceName) async {
  var source = sourceName == serialName
      ? GetIt.I<ISerializer>().loadVocabulary()
      : sourceName == completeName
          ? GetIt.I<ISource>().loadComplete()
          : GetIt.I<ISource>().loadVocabulary(sourceName);

  var items = source.toList();
  if (sourceName == completeName) items = makeUnique(items).toList();

  final err = SourceError.any(sourceName, items);
  if (err != null) return ModelOrError.error(err);

  addSecondary(items);
  addSynonyms(items);

  final serializer = GetIt.I<ISerializer>();
  final model = VocabModel(sourceName, items, serializer);
  return ModelOrError.value(model);
}
