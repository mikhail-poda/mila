import '../Data/Item.dart';
import 'Settings.dart';

abstract class ISource {
  Stream<String> getVocabularies();

  Iterable<Item> loadVocabulary(String fileName);

  Iterable<Item> loadComplete();
}

abstract class ISerializer {
  void push(Item item);

  void sync(List<Item> items);

  int export();

  Future<int> import();

  Iterable<Item> loadVocabulary();

  Settings getSettings();

  setSettings(Settings settings);
}
