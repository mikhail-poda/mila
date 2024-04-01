import '../Data/DataModelSettings.dart';
import '../Data/Item.dart';
import 'Settings.dart';

abstract class ISource {
  Stream<String> getVocabularies();

  Iterable<Item> loadVocabulary(String sourceName);
}

abstract class ISerializer {
  void push(Item item);

  void sync(List<Item> items);

  void reset();

  int export();

  Future<int> import();

  int clearUnused(Iterable<Item> used);

  Statistics statistics();

  Settings getSettings();

  setSettings(Settings settings);
}