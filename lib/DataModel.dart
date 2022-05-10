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
    var items = _items
        .where((item) => item.level != DataModelSettings.doneLevel && item != current)
        .toList();

    Item? next;
    List<Item> filt;

    if (items.isEmpty) return null;

    // try with an existing item for long term memory
    int delta0 = _getDayNo();
    filt = items
        .where((item) => item.level > DataModelSettings.doneLevel)
        .where((item) => DaysLevel.unpack(item.level).daysNo < delta0)
        .toList();
    next = _getRandomItem(filt, 0);
    if (next != null) return next;

    // try with an existing item
    for (int level = 0; level < _settings.levelsNo; level++) {
      filt = items.where((item) => item.level == level).toList();
      next = _getRandomItem(filt, _settings.maxLevelCapacity);
      if (next != null) return next;
    }

    // try with a new item
    filt = items.where((item) => item.level == DataModelSettings.undoneLevel).toList();
    next = _getRandomItem(filt, 0);
    if (next != null) return next;

    // if existing items are sparse and there is no new items
    filt = items.where((item) => item.level < DataModelSettings.doneLevel).toList();
    next = _getRandomItem(items, 0);

    return next;
  }

  int _getDayNo() {
    var now = DateTime.now();
    var ref = DateTime(2022);
    var delta0 = now.difference(ref).inDays;
    return delta0;
  }

  Item? _getRandomItem(List<Item> items, int maxLevelCapacity) {
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
    if (level < progressLevel) {
      item.level = level;
      return;
    }

    // for the last level
    var isTuple = item.level > DataModelSettings.doneLevel;
    var count = !isTuple ? 0 : (DaysLevel.unpack(item.level).level + 1);

    if (count > _settings.goodRepetitionsNo) {
      item.level = DataModelSettings.doneLevel;
    } else {
      int delta0 = _getDayNo();
      item.level = DaysLevel(delta0, count).pack();
    }
  }
}

class DataModelSettings {
  final int levelsNo;
  final int maxLevelCapacity;
  final int goodRepetitionsNo;

  static int doneLevel = 100;
  static int undoneLevel = -1;

  DataModelSettings(this.levelsNo, this.maxLevelCapacity, this.goodRepetitionsNo);
}

class DaysLevel {
  late int level;
  late int daysNo;

  DaysLevel(this.daysNo, this.level);

  DaysLevel.unpack(int value) {
    daysNo = value & 0xffff;
    level = (value >> 16) & 0xffff;
  }

  int pack() {
    return daysNo | (level << 16);
  }
}
