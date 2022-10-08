import 'package:mila/Item.dart';
import 'ISerializer.dart';
import 'Library.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WebSerializer implements ISerializer {
  final Box<int> _levels = Hive.box<int>('level');
  final Box<String> _text = Hive.box<String>('text');

  static init() async {
    await Hive.initFlutter();
    await Hive.openBox<int>('level');
    await Hive.openBox<String>('text');
  }

  @override
  void sync(List<Item> items) async {
    for (var item in items) {
      var name = haserNikud(item.he0);
      var val = _levels.get(name);
      if (val == null) continue;
      item.level = val;
    }
  }

  @override
  void push(Item item) async {
    var hem = item.he0;
    var heh = haserNikud(hem);

    _levels.put(heh, item.level);
    _text.put(heh, '${item.he1}#${item.eng0}');
  }
}
