import 'dart:collection';
import 'dart:math';
import 'package:darq/darq.dart';

import 'AbstractDataModel.dart';
import 'DataModelSettings.dart';
import 'Item.dart';

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
    _excluded.clear();

    for (var item in this) {
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

    var items = where((item) => !_excluded.contains(item))
        .where((item) => !hset.contains(item))
        .orderByDescending((item) => item.level)
        .toList();

    if (items.isEmpty) {
      if (_last.length < 2) return null;
      _last.clear();
      return nextItem(current);
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
    if (item.level == DataModelSettings.tailLevel) {
      _excluded.add(item);
    }
  }

  @override
  Iterable<Item> resetItems(bool Function(Item) func) sync* {
    var items = super.resetItems(func).toList();
    _updateExcludedList();
    yield* items;
  }
}