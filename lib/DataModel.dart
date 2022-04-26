import 'dart:collection';
import 'Item.dart';
import 'dart:math';

class DataModel with IterableMixin<Item> {
  final List<Item> _items;
  final _random = Random();
  final DataModelSettings _settings;

  DataModel(this._items, this._settings);

  Item operator [](int index) => _items[index];

  @override
  Iterator<Item> get iterator => _items.iterator;

  Item? nextGuess(Item? current) {
    var count = _settings.levelsNo + _settings.goodRepetitionsNo;
    var items = _items
        .where((item) =>
            item.level != DataModelSettings.doneLevel && item != current)
        .toList();

    if (items.isEmpty) return null;

    // try with an existing item
    for (int i = 0; i < count; i++) {
      Item? next = getRandomItem(items, i, _settings.maxLevelCapacity);
      if (next != null) return next;
    }

    // try with a new item
    return getRandomItem(items, DataModelSettings.undoneLevel, 0);
  }

  Item? getRandomItem(List<Item> items_, int level, int maxLevelCapacity) {
    var items = items_.where((item) => item.level == level).toList();
    if (items.isEmpty) return null;

    var size = items.length;
    var maxi = max(size, maxLevelCapacity);
    var ind = _random.nextInt(maxi);
    var next = ind < size ? items[ind] : null;
    return next;
  }

  void setLevel(Item item, int level) {
    // for all but the last level
    var progressLevel = _settings.levelsNo - 1;
    if (item.level < progressLevel || level < progressLevel) {
      item.level = level;
      return;
    }

    // for the last level
    item.level++;
    var doneLevel = _settings.levelsNo + _settings.goodRepetitionsNo - 1;
    if (item.level >= doneLevel) {
      item.level = DataModelSettings.doneLevel;
    }
  }
}

class DataModelSettings {
  final int levelsNo;
  final int maxLevelCapacity;
  final int goodRepetitionsNo;

  static int doneLevel = 100;
  static int undoneLevel = -1;

  DataModelSettings(
      this.levelsNo, this.maxLevelCapacity, this.goodRepetitionsNo);
}
