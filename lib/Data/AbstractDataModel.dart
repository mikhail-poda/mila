import 'dart:collection';

import 'DataModelSettings.dart';
import 'Item.dart';

abstract class AbstractDataModel with IterableMixin<Item> {
  final List<Item> _items;

  AbstractDataModel(this._items);

  String get message => '';

  Item operator [](int index) => _items[index];

  @override
  int get length => _items.length;

  @override
  Iterator<Item> get iterator => _items.iterator;

  Item? nextItem(Item? current);

  void setLevel(Item item, int level);

  Iterable<Item> resetItems(bool Function(Item) func) sync* {
    for (var item in _items) {
      if (func(item)) {
        item.level = DataModelSettings.undoneLevel;
        yield item;
      }
    }
  }

  int getLevel(int itemLevel, int jump) {
    if (jump <= DataModelSettings.undoneLevel) {
      return jump;
    }

    // learning mode
    if (itemLevel < DataModelSettings.maxLevel) {
      if (jump == Level.again.level) return Level.again.level;
      if (jump == Level.good.level) return Level.good.level;

      // repeat in 16 days 2^(9-5) if the vocable is well known
      if (itemLevel <= DataModelSettings.undoneLevel) return DataModelSettings.maxLevel + 4;
      return (itemLevel < Level.easy.level) ? Level.easy.level : itemLevel + 1;
    } else
    // repetition mode
    {
      if (jump == Level.again.level) return itemLevel ~/ 2;
      if (jump == Level.good.level) return itemLevel - 1;
      return itemLevel + 1;
    }
  }
}
