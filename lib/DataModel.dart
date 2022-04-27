import 'dart:collection';
import 'dart:math';

import 'Item.dart';

abstract class AbstractDataModel with IterableMixin<Item> {
  final List<Item> _items;

  AbstractDataModel(this._items);

  Item operator [](int index) => _items[index];

  @override
  Iterator<Item> get iterator => _items.iterator;

  void setLevel(Item item, int level);

  Item? nextItem(Item? current);
}

class SequentialDataModel extends AbstractDataModel {
  int _index = 0;

  SequentialDataModel(List<Item> items) : super(items);

  void reset() => _index = 0;

  @override
  Item? nextItem(Item? current) {
    var ind = _index++;
    return _items[ind % _items.length];
  }

  @override
  void setLevel(Item item, int level) {
    item.level = level;
  }
}

class RandomDataModel extends AbstractDataModel {
  final _random = Random();
  late DataModelSettings _settings;

  RandomDataModel(List<Item> items, DataModelSettings settings) : super(items) {
    _settings = settings;
  }

  @override
  Item? nextItem(Item? current) {
    var count = _settings.levelsNo + _settings.goodRepetitionsNo;
    var items = _items
        .where((item) =>
            item.level != DataModelSettings.doneLevel && item != current)
        .toList();

    if (items.isEmpty) return null;

    // try with an existing item
    for (int level = 0; level < count; level++) {
      Item? next = getRandomItem(items, level, _settings.maxLevelCapacity);
      if (next != null) return next;
    }

    // try with a new item
    return getRandomItem(items, DataModelSettings.undoneLevel, 0);
  }

  Item? getRandomItem(List<Item> items_, int level, int maxLevelCapacity) {
    var items = items_.where((item) => item.level == level).toList();
    if (items.isEmpty) return null;

    var size = items.length;
    var maxi = maxLevelCapacity == 0 ? size : maxLevelCapacity;
    var ind = _random.nextInt(maxi);
    var next = ind < size ? items[ind] : null;
    return next;
  }

  @override
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
