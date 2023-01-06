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

    //----------------------- map values 1-3 to 1-5

    // lowest knowledge, if prev. known then second-lowest
    // map 1 to [1,2]
    if (value == DataModelSettings.valueAgain) {
      return level < 3 ? 1 : 2;
    }

    // certain knowledge, if prev. low then stay lower
    // map 2 to [3,4]
    if (value == DataModelSettings.valueGood) {
      return level < 3 ? 3 : 4;
    }

    //---------------- value == DataModelSettings.valueEasy which is the highest

    // repeat in 16 days 2^(9-5) if the vocable is well known
    if (level == DataModelSettings.undoneLevel) return 9;

    // repeat again
    if (level < 3) return 4;

    // high knowledge
    if (level < 5) return 5;

    // count up
    return level + 1;
  }
}
