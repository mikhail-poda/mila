import 'AbstractDataModel.dart';
import 'DataModelSettings.dart';
import 'Item.dart';

class SequentialDataModel extends AbstractDataModel {
  int _index = 0;

  SequentialDataModel(List<Item> items) : super(items);

  @override
  Item? nextItem(Item? current) {
    var ind = _index++;
    return this[ind % length];
  }

  @override
  void setLevel(Item item, int value) {
    var level = getLevel(item.level, value);
    if (item.level < DataModelSettings.maxLevel || level < DataModelSettings.maxLevel) {
      item.level = level;
    }
    item.lastUse = DateTime.now();
  }
}
