import '../Data/Item.dart';
import 'Settings.dart';

abstract class ISource {
  Stream<String> getVocabularies();

  Iterable<Item> loadVocabulary(String sourceName);
}

abstract class ISerializer {
  void push(Item item);

  void sync(List<Item> items);

  int export();

  Future<int> import();

  int clear(int days);

  Iterable<Item> loadVocabulary();

  Settings getSettings();

  setSettings(Settings settings);
}
