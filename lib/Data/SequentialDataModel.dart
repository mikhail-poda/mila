import 'AbstractDataModel.dart';
import 'DataModelSettings.dart';
import 'Item.dart';

class SequentialDataModel extends AbstractDataModel {
  int _index = 0;

  SequentialDataModel(List<Item> items) : super(items);

  @override
  String get message => "${1 + ((_index - 1) % length)} / $length";

  @override
  Item? nextItem(Item? current) {
    var ind = _index++;
    return this[ind % length];
  }

  @override
  void setLevel(Item item, int level) {
    if (item.level <= DataModelSettings.undoneLevel && level == Level.again.level) return;

    item.level = getLevel(item.level, level);
    item.lastUse = DateTime.now();
  }
}
