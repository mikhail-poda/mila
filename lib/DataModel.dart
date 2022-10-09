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

  void setLevel(Item item, int level) {
    if (level < DataModelSettings.levelsNo || item.level < DataModelSettings.levelsNo) {
      item.level = level;
    } else {
      item.level++;
    }
    item.lastUse = DateTime.now();
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
}

class RandomDataModel extends AbstractDataModel {
  final _random = Random();
  final _last = Queue<Item>();
  final _unused = HashSet<Item>();
  final _now = DateTime.now();

  RandomDataModel(List<Item> items) : super(items) {
    for (var item in items) {
      if (item.level == DataModelSettings.hiddenLevel) {
        _unused.add(item);
      } else {
        var diff = item.level - DataModelSettings.levelsNo;
        if (diff < 0) continue;

        var days = pow(2, diff) as int;
        var next = item.lastUse!.add(Duration(days: days));

        if (next.isAfter(_now)) _unused.add(item);
      }
    }
  }

  @override
  Item? nextItem(Item? current) {
    if (current != null) _last.addFirst(current);
    if (_last.length > DataModelSettings.minExclude) _last.removeLast();

    var hset = HashSet.of(_last);

    var items = _items
        .where((item) => !_unused.contains(item))
        .where((item) => !hset.contains(item))
        .orderByDescending((item) => item.level)
        .toList();

    if (items.isEmpty) {
      // TODO: go thru the last
      return null;
    }

    var list = <Item>[];

    for (var item in items) {
      var num = max(1, 1 + DataModelSettings.levelsNo - item.level);
      list.addAll(List.filled(num, item));
      if (list.length > DataModelSettings.maxCapacity) break;
    }

    var next = _getRandomItem(list);
    if (next != null) return next;

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
    super.setLevel(item, level);

    // do no use these items any more in this session
    if (level >= DataModelSettings.levelsNo) _unused.add(item);
    if (level == DataModelSettings.hiddenLevel) _unused.add(item);
  }
}

class DataModelSettings {
  static int levelsNo = 4; // again, hard, good. easy
  static int minExclude = 3; // how many times a used item will be excluded
  static int maxCapacity = 25; // max pool size, "again" takes 4 places, "easy" or "undone" 1 place
  static int undoneLevel = 0;
  static int hiddenLevel = -1;
}
