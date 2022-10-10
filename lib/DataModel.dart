import 'dart:collection';
import 'dart:math';
import 'package:darq/darq.dart';

import 'Item.dart';

abstract class AbstractDataModel with IterableMixin<Item> {
  final List<Item> _items;

  AbstractDataModel(this._items);

  Item operator [](int index) => _items[index];

  @override
  Iterator<Item> get iterator => _items.iterator;

  Item? nextItem(Item? current);

  void setLevel(Item item, int level);
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
  void setLevel(Item item, int level) {
    if (level < DataModelSettings.levelsNo || item.level < DataModelSettings.levelsNo) {
      item.level = level;
    }
    item.lastUse = DateTime.now();
  }
}

class RandomDataModel extends AbstractDataModel {
  final _random = Random();
  final _last = Queue<Item>();
  final _unused = HashSet<Item>();
  var _now = DateTime.now();

  RandomDataModel(List<Item> items) : super(items) {
    _reset();
  }

  void _reset() {
    for (var item in _items) {
      if (item.level == DataModelSettings.hiddenLevel) {
        _unused.add(item);
      } else {
        var diff = item.level - DataModelSettings.maxLevel;
        if (diff < 0) continue;

        var days = pow(2, diff) as int;
        var next = item.lastUse!.add(Duration(days: days));

        if (next.isAfter(_now)) _unused.add(item);
      }
    }
  }

  @override
  Item? nextItem(Item? current) {
    // once per hour reload easy (done) items
    if (_now.add(const Duration(hours: 1)).isBefore(DateTime.now())) {
      _now = DateTime.now();
      _reset();
    }

    if (current != null) _last.addFirst(current);
    if (_last.length > DataModelSettings.minExclude) _last.removeLast();

    var hset = HashSet.of(_last);

    var items = _items
        .where((item) => !_unused.contains(item))
        .where((item) => !hset.contains(item))
        .orderByDescending((item) => item.level)
        .toList();

    if (items.isEmpty) {
      return _getRandomItem(_items);
    }

    var list = <Item>[];

    for (var item in items) {
      var num = max(1, 1 + DataModelSettings.maxLevel - item.level);
      list.addAll(List.filled(num, item));
      if (list.length > DataModelSettings.maxCapacity) break;
    }

    return _getRandomItem(list);
  }

  Item? _getRandomItem(List<Item> items) {
    if (items.isEmpty) return null;
    var size = items.length;
    var ind = _random.nextInt(size);
    return items[ind];
  }

  @override
  void setLevel(Item item, int level) {
    if (level == DataModelSettings.maxLevel && item.level == DataModelSettings.undoneLevel) {
      item.level = DataModelSettings.maxLevel + 3;
    } else if (level < DataModelSettings.maxLevel || item.level < DataModelSettings.maxLevel) {
      item.level = level;
    } else {
      item.level++;
    }
    item.lastUse = DateTime.now();

    // do no use these items any more in this session
    if (level >= DataModelSettings.maxLevel) _unused.add(item);
    if (level == DataModelSettings.hiddenLevel) _unused.add(item);
  }
}

class DataModelSettings {
  static const levels = ["Again", "Hard", "Good", "Easy"];

  static const levelsNo = 4;
  static const maxLevel = 4;
  static const minExclude = 4; // how many times a used item will be excluded
  static const maxCapacity = 30; // max pool size, "again" takes 4 places, "easy" or "undone" 1 pl.
  static const undoneLevel = 0;
  static const hiddenLevel = -1;
}
