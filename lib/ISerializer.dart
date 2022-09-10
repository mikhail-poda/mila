import 'Item.dart';

abstract class ISerializer {
  void push(Item item);

  void sync(List<Item> items);
}
