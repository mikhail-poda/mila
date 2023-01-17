import '../Data/DataModelSettings.dart';
import '../Data/Item.dart';
import 'Settings.dart';

abstract class ISource {
  Stream<String> getVocabularies();

  Iterable<Item> loadVocabulary(String sourceName);

  Iterable<Item> loadComplete();
}

abstract class ISerializer {
  void push(Item item);

  void sync(List<Item> items);

  int export();

  Future<int> import();

  int clearUnused(Iterable<Item> used);

  Statistics statistics();

  Settings getSettings();

  setSettings(Settings settings);
}