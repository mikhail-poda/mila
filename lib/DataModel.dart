import 'dart:collection';
import 'dart:math';
import 'package:darq/darq.dart';

import 'Item.dart';

abstract class AbstractDataModel with IterableMixin<Item> {
  final List<Item> _items;
  final DataModelSettings _settings;

  AbstractDataModel(this._items, this._settings);

  Item operator [](int index) => _items[index];

  @override
  Iterator<Item> get iterator => _items.iterator;

  void setLevel(Item item, int level);

  Item? nextItem(Item? current);
}

class SequentialDataModel extends AbstractDataModel {
  int _index = 0;

  SequentialDataModel(List<Item> items, DataModelSettings settings) : super(items, settings);

  @override
  Item? nextItem(Item? current) {
    var ind = _index++;
    return _items[ind % _items.length];
  }

  @override
  void setLevel(Item item, int level) {
    // set new level if still learning, if already good then do nothing
    if (level < _settings.levelsNo - 1) {
      item.level = level;
    } else if (item.level < _settings.levelsNo - 1) {
      int delta0 = _getDayNo();
      item.level = DaysLevelTuple(delta0, 1).pack();
    }
  }
}

class RandomDataModel extends AbstractDataModel {
  final _random = Random();
  Item? _last;

  RandomDataModel(List<Item> items, DataModelSettings settings) : super(items, settings);

  @override
  Item? nextItem(Item? current) {
    var items = _items
        .where((item) => item.level != DataModelSettings.doneLevel)
        .where((item) => item != current)
        .where((item) => item != _last)
        .toList();

    Item? next;
    _last = current;
    var filt = <Item>[];

    if (items.isEmpty) return null;

    // start with an existing item for long-term memory
    int dayNo = _getDayNo();
    var filt0 = items
        .where((item) => item.level > DataModelSettings.doneLevel)
        .where((item) => DaysLevelTuple.unpack(item.level).dayNo < dayNo)
        .toList();

    var filt1 = items
        .where((item) => item.level < DataModelSettings.doneLevel)
        .where((item) => item.level > DataModelSettings.undoneLevel);

    var filt2 = items.where((item) => item.level == DataModelSettings.undoneLevel);

    for (var item in filt1.concat(filt2)) {
      filt.addAll(List.filled(_settings.levelsNo - item.level, item));
      if (filt.length > _settings.maxCapacity) break;
    }

    filt.addAll(filt0);

    next = _getRandomItem(filt);
    if (next != null) return next;

    // as last show omitted items
    filt = items.where((item) => item.level == DataModelSettings.omitLevel).toList();
    next = _getRandomItem(filt);

    return next;
  }

  Item? _getRandomItem(List<Item> items) {
    if (items.isEmpty) return null;
    var size = items.length;
    var ind = _random.nextInt(size);
    return items[ind];
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

    // if the knowledge is perfect for the first time than give another try today
    if (!isTuple) {
      item.level = DataModelSettings.doneLevel + 1;
      return;
    }

    var count = isTuple ? DaysLevelTuple.unpack(item.level).level : 0;

    count++;

    if (count > _settings.goodRepetitionsNo) {
      item.level = DataModelSettings.doneLevel;
    } else {
      int delta0 = _getDayNo();
      item.level = DaysLevelTuple(delta0, count).pack();
    }
  }
}

int _getDayNo() {
  var now = DateTime.now();
  var ref = DateTime(2022);
  var delta0 = now.difference(ref).inDays;
  return delta0;
}

class DataModelSettings {
  final int levelsNo;
  final int maxCapacity;
  final int goodRepetitionsNo;

  static int doneLevel = 100;
  static int undoneLevel = -1;
  static int omitLevel = -2;

  DataModelSettings(this.levelsNo, this.maxCapacity, this.goodRepetitionsNo);
}

class DaysLevelTuple {
  late int level;
  late int dayNo;

  DaysLevelTuple(this.dayNo, this.level);

  DaysLevelTuple.unpack(int value) {
    dayNo = value & 0xffff;
    level = (value >> 16) & 0xffff;
  }

  int pack() {
    return dayNo | (level << 16);
  }
}
