import 'dart:convert';
import 'dart:html';
import 'package:file_picker/file_picker.dart';

import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../Data/DataModelSettings.dart';
import '../Data/Item.dart';
import '../Library/Library.dart';
import 'ISerializer.dart';

class HiveObsolete implements ISerializer {
  static const _txtBox = 'text.3';
  static const _levBox = 'level.3';

  final _formatter = DateFormat('yyyy.MM.dd');
  final _levels = Hive.box<int>(_levBox);
  final _text = Hive.box<String>(_txtBox);

  static init() async {
    await Hive.openBox<int>(_levBox);
    await Hive.openBox<String>(_txtBox);
  }

  @override
  void sync(List<Item> items) async {
    for (var item in items) {
      var name = item.id;
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
    final heh = item.id;

    if (item.level == DataModelSettings.undoneLevel) {
      _text.delete(heh);
      _levels.delete(heh);
      return;
    }

    final now = DateTime.now();
    final date = _formatter.format(now);

    _levels.put(heh, item.level);
    _text.put(heh, '${item.target}#${item.translation}#$date');
  }

  @override
  Iterable<Item> loadVocabulary() sync* {
    for (var str in _text.values) {
      final cell = str.split('#');
      if (cell[0].contains(',') || cell[0].contains('/')) continue;

      yield AdditionalItem('', cell[0], cell[1]);
    }
  }

  List<String> asLines() {
    var buf = <String>['target\ttranslation\tlevel\tlast_use'];

    for (var key in _text.keys) {
      var str = key as String;
      var cell = _text.get(str)!.split('#');
      if (cell.length < 3) continue;

      var he0 = cell[0];
      var eng = cell[1];
      var date = cell[2];
      var level = _levels.get(str);

      if (he0.contains(',') || he0.contains('/') || he0.contains('\\')) continue;

      buf.add('$he0\t$eng\t$level\t$date');
    }

    return buf;
  }

  @override
  int export() {
    final lines = asLines();
    final text = lines.join('\n');
    final bytes = utf8.encode(text);
    final content = base64Encode(bytes);

    AnchorElement(href: "data:application/octet-stream;charset=utf-16le;base64,$content")
      ..setAttribute("download", "file.txt")
      ..click();

    return lines.length;
  }

  @override
  Future<int> import() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return Future<int>.value(0);

    final bytes = result.files.first.bytes;

    var num = 0;
    var str = const Utf8Codec().decode(bytes!);
    var lines = str.split('\n');

    for (var line in lines) {
      var cell = line.split('\t');
      if (!hasHebrew(cell[0])) continue;

      var he0 = cell[0];
      var eng = cell[1];
      var date = cell[3];
      var level = int.parse(cell[2]);

      num++;
      var heh = haserNikud(he0);

      _levels.put(heh, level);
      _text.put(heh, '$he0#$eng#$date');
    }

    return Future<int>.value(num);
  }
}
