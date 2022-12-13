import 'Item.dart';

abstract class ISource {
  Future<List<String>> getVocabularies();

  Stream<List<String>> loadVocabulary(String fileName);

  Stream<List<String>> loadComplete();
}

abstract class ISerializer {
  void push(Item item);

  void sync(List<Item> items);

  Stream<List<String>> loadVocabulary();
}
