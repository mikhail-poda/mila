import 'dart:collection';
import 'dart:math';
import 'package:darq/darq.dart';

import 'Item.dart';

abstract class AbstractDataModel with IterableMixin<Item> {
  final List<Item> _items;

  AbstractDataModel(this._items);

  Item operator [](int index) => _items[index];

  @override
  int get length => _items.length;

  @override
  Iterator<Item> get iterator => _items.iterator;

  Item? nextItem(Item? current);

  void setLevel(Item item, int value);

  void resetItems() {
    for (var item in _items) {
      item.level = DataModelSettings.undoneLevel;
    }
  }
}

class SequentialDataModel extends AbstractDataModel {
  int _index = 0;

  SequentialDataModel(List<Item> items) : super(items);

  @override
  Item? nextItem(Item? current) {
    var ind = _index++;
    return _items[ind % _items.length];
  }

  @override
  void setLevel(Item item, int value) {
    var level = getLevel(item.level, value);
    if (item.level < DataModelSettings.maxLevel || level < DataModelSettings.maxLevel) {
      item.level = level;
    }
    item.lastUse = DateTime.now();
  }
}

class RandomDataModel extends AbstractDataModel {
  final _last = Queue<Item>();
  final _random = Random();
  final _excluded = HashSet<Item>();

  DateTime? _lastReset;

  RandomDataModel(List<Item> items) : super(items) {
    _updateExcludedList();
  }

  void _updateExcludedList() {
    _lastReset = DateTime.now();

    for (var item in _items) {
      if (item.level == DataModelSettings.hiddenLevel) {
        _excluded.add(item);
      } else {
        var diff = item.level - DataModelSettings.maxLevel;
        if (diff < 0) continue;

        var days = pow(2, diff) as int;
        var next = item.lastUse!.add(Duration(days: days));

        if (next.isAfter(_lastReset!)) _excluded.add(item);
      }
    }
  }

  @override
  Item? nextItem(Item? current) {
    // once per hour reload easy (done) items
    if (_lastReset!.add(const Duration(hours: 1)).isBefore(DateTime.now())) {
      _updateExcludedList();
    }

    if (current != null) _last.addFirst(current);
    if (_last.length > DataModelSettings.minExclude) _last.removeLast();

    var hset = HashSet.of(_last);

    var items = _items
        .where((item) => !_excluded.contains(item))
        .where((item) => !hset.contains(item))
        .orderByDescending((item) => item.level)
        .toList();

    if (items.isEmpty) {
      return null;
    }

    var list = <Item>[];

    for (var item in items) {
      var num = max(1, 1 + DataModelSettings.maxLevel - item.level);
      list.addAll(List.filled(num, item));
      if (list.length > DataModelSettings.maxCapacity) break;
    }

    return _getRandomItem(list);
  }

  Item _getRandomItem(List<Item> items) {
    var size = items.length;
    var ind = _random.nextInt(size);
    return items[ind];
  }

  @override
  void setLevel(Item item, int value) {
    item.level = getLevel(item.level, value);
    item.lastUse = DateTime.now();

    // do no use these items any more in this session
    if (item.level >= DataModelSettings.maxLevel) _excluded.add(item);
    if (item.level == DataModelSettings.hiddenLevel) _excluded.add(item);
    if (item.level == DataModelSettings.tailLevel && value == DataModelSettings.tailLevel) {
      _excluded.add(item);
    }
  }

  @override
  void resetItems() {
    super.resetItems();
    _excluded.clear();
  }
}

class DataModelSettings {
  static const levels = ["Again", "Good", "Easy"];

  static const value1 = 1;
  static const value2 = 2;
  static const value3 = 3;

  static const maxLevel = 5;
  static const minExclude = 5; // how many times a used item will be excluded
  static const maxCapacity = 30; // max pool size, "again" takes 4 places, "easy" or "undone" 1 pl.
  static const undoneLevel = 0;
  static const tailLevel = -1;
  static const hiddenLevel = -2;
}

int getLevel(int level, int value) {
  if (value == DataModelSettings.undoneLevel ||
      value == DataModelSettings.hiddenLevel ||
      value == DataModelSettings.tailLevel) {
    return value;
  }

  if (value == DataModelSettings.value1) {
    return level < 3 ? 1 : 2;
  }

  if (value == DataModelSettings.value2) {
    return level < 3 ? 3 : 4;
  }

  return level == 0
      ? 8
      : level < 3
          ? 4
          : level < 5
              ? 5
              : (level + 1);
}
