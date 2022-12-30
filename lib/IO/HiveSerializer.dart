import 'dart:convert';
import 'dart:html';
import 'package:darq/darq.dart';
import 'package:file_picker/file_picker.dart';

import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mila/IO/HiveObsolete.dart';

import '../Data/DataModelSettings.dart';
import '../Data/Item.dart';
import '../Library/Library.dart';
import 'ISerializer.dart';
import 'SerialItem.dart';

class HiveSerializer implements ISerializer {
  final _formatter = DateFormat('yyyy.MM.dd');
  static late Box<SerialItem> _box;

  static init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SerialItemAdapter());
    _box = await Hive.openBox<SerialItem>('ItemBox.1');

    //await HiveObsolete.init();
  }

  @override
  void sync(List<Item> items) async {
    //var obs = HiveObsolete();
    //var lines = obs.asLines();
    //_importLines(lines);

    for (var item in items) {
      var obj = _box.get(item.id);
      if (obj == null) continue;

      item.level = obj.level;
      item.lastUse = obj.lastUse;
    }
  }

  @override
  void push(Item item) async {
    if (item.level == DataModelSettings.undoneLevel) {
      _box.delete(item.id);
      return;
    } else {
      var obj = SerialItem.init(
          item.identifier, item.target, item.translation, item.level, item.lastUse, item.phonetic);
      _box.put(item.id, obj);
    }
  }

  @override
  Iterable<Item> loadVocabulary() sync* {
    for (var obj in _box.values) {
      yield AdditionalItem(obj.identifier, obj.target, obj.translation);
    }
  }

  List<String> asLines() {
    var buf = <String>['identifier\ttarget\ttranslation\tlevel\tlast_use\tphonetic'];

    for (var obj in _box.values) {
      buf.add(
          '${obj.identifier}\t${obj.target}\t${obj.translation}\t${obj.level}\t${obj.lastUse}\t${obj.phonetic}');
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

    var str = const Utf8Codec().decode(bytes!);
    var lines = str.split('\n');
    var num = _importLines(lines);

    return Future<int>.value(num);
  }

  int _importLines(List<String> lines) {
    var num = 0;
    var header = lines.first.split('\t').select((x, i) => x.trim()).toList();
    var mapper = SerialMapper(header);

    for (var line in lines.skip(1)) {
      var cell = line.split('\t').select((x, i) => x.trim()).toList();
      if (!hasHebrew(cell[0])) continue;

      num++;
      var target = cell[mapper.target];
      var translation = cell[mapper.translation];
      var level = int.parse(cell[mapper.level]);
      var lastUse = _formatter.parse(cell[mapper.lastUse]);
      var identifier = mapper.identifier < 0 ? '' : cell[mapper.identifier];
      var phonetic = mapper.phonetic < 0 ? '' : cell[mapper.phonetic];

      var obj = SerialItem.init(identifier, target, translation, level, lastUse, phonetic);
      _box.put(obj.id, obj);
    }
    return num;
  }
}

class SerialMapper {
  late int target = -1;
  late int identifier = -1;
  late int phonetic = -1;
  late int translation = -1;
  late int level = -1;
  late int lastUse = -1;

  SerialMapper(List<String> line) {
    target = line.indexOf('target');
    identifier = line.indexOf('identifier');
    phonetic = line.indexOf('phonetic');
    translation = line.indexOf('translation');
    level = line.indexOf('level');
    lastUse = line.indexOf('last_use');
  }
}
