import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../Constants.dart';
import '../IO/ISerializer.dart';

final vocabulariesListProvider = FutureProvider<List<String>>((ref) async => getVocabularies());
final vocabularyNameProvider = StateProvider<String>((ref) => "");

Future<List<String>> getVocabularies() async {
  var list = await GetIt.I<ISource>().getVocabularies().toList(); // add new item to a new list

  list.insert(0, completeName);
  list.insert(1, serialName);
  return list;
}