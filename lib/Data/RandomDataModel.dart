import 'dart:collection';
import 'dart:math';
import 'package:darq/darq.dart';

import 'AbstractDataModel.dart';
import 'DataModelSettings.dart';
import 'Item.dart';

class RandomDataModel extends AbstractDataModel {
  final _waitQueue = Queue<Item>();
  final _random = Random();

  RandomDataModel(List<Item> items) : super(items);

  @override
  String get message {
    var num = _pendingNo;
    if (num == null || num == 0) return '';
    return num.toString();
  }

  int? get _pendingNo {
    var now = DateTime.now();
    return where((item) => item.level >= DataModelSettings.hours3Index && item.nextUse.isBefore(now))
        .length;
  }

  @override
  Item? nextItem(Item? current) {
    if (current != null) _waitQueue.addFirst(current);
    if (_waitQueue.length > DataModelSettings.waitQueueWidth) _waitQueue.removeLast();

    var now = DateTime.now();
    var hset = HashSet.of(_waitQueue);

    var items = this
        .where((item) => !hset.contains(item))
        .where((item) => item.level >= DataModelSettings.undoneLevel )
        .where((item) => item.level == DataModelSettings.undoneLevel || item.nextUse.isBefore(now))
        .orderByDescending((item) => item.level)
        .toList();

    // special case - only few last items are left
    if (items.isEmpty) {
      if (_waitQueue.length < 2) return null;
      _waitQueue.clear();
      return nextItem(current);
    }

    var level = items[0].level;
    var pool = items.takeWhile((x) => x.level == level).toList();

    return _getRandomItem(pool);
  }

  @override
  void setSkill(Item item, Skill skill) {
    item.level = getLevel(item.level, skill);
    item.lastUse = DateTime.now();
  }

  Item _getRandomItem(List<Item> items) {
    var size = items.length;
    var ind = _random.nextInt(size);
    return items[ind];
  }

  @override
  Iterable<Item> resetItems(bool Function(Item) func) sync* {
    var items = super.resetItems(func).toList();
    yield* items;
  }
}
