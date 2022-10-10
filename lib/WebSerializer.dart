import 'package:intl/intl.dart';
import 'package:mila/Item.dart';
import 'ISerializer.dart';
import 'Library.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WebSerializer implements ISerializer {
  static const _levBox = 'level.1';
  static const _txtBox = 'text.1';

  final _formatter = DateFormat('yyyy.MM;dd');
  final _levels = Hive.box<int>(_levBox);
  final _text = Hive.box<String>(_txtBox);

  static init() async {
    await Hive.initFlutter();
    await Hive.openBox<int>(_levBox);
    await Hive.openBox<String>(_txtBox);
  }

  @override
  void sync(List<Item> items) async {
    for (var item in items) {
      var name = haserNikud(item.he0);
      var level = _levels.get(name);
      if (level == null) continue;
      item.level = level;

      var date = _text.get(name)!.split('#').last;
      item.lastUse = _formatter.parse(date);
    }
  }

  @override
  void push(Item item) async {
    var hem = item.he0;
    var heh = haserNikud(hem);

    final now = DateTime.now();
    final formatted = _formatter.format(now);

    _levels.put(heh, item.level);
    _text.put(heh, '${item.he1}#${item.eng0}#$formatted');
  }
}
