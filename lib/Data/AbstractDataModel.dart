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

  void setLevel(Item item, int level) {
    item.level = level;
    item.lastUse = DateTime.now();
  }

  void setSkill(Item item, Skill skill);

  Iterable<Item> resetItems(bool Function(Item) func) sync* {
    for (var item in _items) {
      if (func(item)) {
        item.level = DataModelSettings.undoneLevel;
        yield item;
      }
    }
  }

  int getLevel(int fromLevel, Skill skill) {
    var toLevel = _getLevelInternal(fromLevel, skill);
    return toLevel < DataModelSettings.startLevel
        ? DataModelSettings.startLevel
        : toLevel >= DataModelSettings.fibonacci.length
            ? (DataModelSettings.fibonacci.length - 1)
            : toLevel;
  }

  int _getLevelInternal(int fromLevel, Skill skill) {
    if (fromLevel == DataModelSettings.undoneLevel) {
      return switch (skill) {
        Skill.again => DataModelSettings.startLevel,
        Skill.good => DataModelSettings.min10Index,
        Skill.easy => DataModelSettings.dayIndex,
      };
    }

    if (fromLevel <= DataModelSettings.min10Index) {
      return switch (skill) {
        Skill.again => fromLevel - 1,
        Skill.good => fromLevel + 2,
        Skill.easy => fromLevel + 4,
      };
    }

    if (fromLevel <= DataModelSettings.hourIndex) {
      return switch (skill) {
        Skill.again => fromLevel - 2,
        Skill.good => fromLevel + 0,
        Skill.easy => fromLevel + 3,
      };
    }

    if (fromLevel <= DataModelSettings.dayIndex) {
      return switch (skill) {
        Skill.again => fromLevel - 4,
        Skill.good => fromLevel - 2,
        Skill.easy => fromLevel + 2,
      };
    }

    return switch (skill) {
      Skill.again => fromLevel - 6,
      Skill.good => fromLevel - 3,
      Skill.easy => fromLevel + 1,
    };
  }
}
