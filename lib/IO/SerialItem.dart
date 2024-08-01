
import 'package:hive/hive.dart';

import '../Data/DataModelSettings.dart';
import '../Data/Item.dart';
import '../Library/Library.dart';

part 'SerialItem.g.dart';

@HiveType(typeId: 1)
class SerialItem implements IItem {
  @HiveField(0)
  late String identifier;

  @override
  @HiveField(1)
  late String target;

  @override
  @HiveField(2)
  late String translation;

  @override
  @HiveField(3)
  late int level;

  @HiveField(4)
  late DateTime lastUse;

  @HiveField(5)
  late String phonetic;

  String get id => haserNikud(target) + identifier;

  SerialItem();

  SerialItem.init(
      this.identifier, this.target, this.translation, this.level, this.lastUse, this.phonetic);

  DateTime get nextUse {
    var offset = DataModelSettings.calcOffset(level);
    var next = lastUse.add(Duration(minutes: offset));
    return next;
  }
}
