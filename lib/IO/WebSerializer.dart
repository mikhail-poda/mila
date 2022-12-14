import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../Data/DataModelSettings.dart';
import '../Data/Item.dart';
import 'ISerializer.dart';

class WebSerializer implements ISerializer {
  static const _txtBox = 'text.3';
  static const _levBox = 'level.3';

  final _formatter = DateFormat('yyyy.MM.dd');
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
      var name = item.Id;
      var level = _levels.get(name);
      if (level == null) continue;
      item.level = level;

      var date = _text.get(name)!.split('#').last;
      item.lastUse = _formatter.parse(date);
    }

    // move to the end of the list
    for (var item in items) {
      items.remove(item);
      items.add(item);
    }
  }

  @override
  void push(Item item) async {
    final heh = item.Id;

    if (item.level == DataModelSettings.undoneLevel) {
      _text.delete(heh);
      _levels.delete(heh);
      return;
    }

    final now = DateTime.now();
    final date = _formatter.format(now);

    _levels.put(heh, item.level);
    _text.put(heh, '${item.he0}#${item.eng0}#$date');
  }

  @override
  Stream<List<String>> loadVocabulary() async* {
    for (var str in _text.values) {
      final cell = str.split('#');
      if (cell[0].contains(',')) continue;

      yield [cell[0], cell[1]];
    }
  }
}
