import 'dart:collection';

import 'DataModelSettings.dart';
import 'Item.dart';

abstract class AbstractDataModel with IterableMixin<Item> {
  final List<Item> _items;

  AbstractDataModel(this._items);

  int? get pendingNo => null;

  Item operator [](int index) => _items[index];

  @override
  int get length => _items.length;

  @override
  Iterator<Item> get iterator => _items.iterator;

  Item? nextItem(Item? current);

  void setLevel(Item item, int value);

  Iterable<Item> resetItems(bool Function(Item) func) sync* {
    for (var item in _items) {
      if (func(item)) {
        item.level = DataModelSettings.undoneLevel;
        yield item;
      }
    }
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

    // value == DataModelSettings.value3 which is the highest
    return level == 0
        ? 8
        : level < 3
            ? 4
            : level < 5
                ? 5
                : (level + 1);
  }
}
