import 'dart:convert';
import 'dart:io' as io;

import 'package:darq/darq.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mila/IO/Settings.dart';

import '../Data/DataModelSettings.dart';
import '../Data/Item.dart';
import '../Library/Library.dart';
import 'ISerializer.dart';
import 'SerialItem.dart';

class HiveSerializer implements ISerializer {
  static final formatter = DateFormat('yyyy.MM.dd hh:mm:ss');

  static late Box<SerialItem> _itemsBox;
  static late Box<Settings> _settingsBox;

  static init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(SettingsAdapter());
    Hive.registerAdapter(SerialItemAdapter());

    _itemsBox = await Hive.openBox<SerialItem>('ItemBox.1');
    _settingsBox = await Hive.openBox<Settings>('SettingsBox.1');
  }

  @override
  void sync(List<Item> items) async {
    for (var item in items) {
      var obj = _itemsBox.get(item.id);
      if (obj == null) continue;

      item.level = obj.level;
      item.lastUse = obj.lastUse;
    }
  }

  @override
  void push(Item item) async {
    if (item.level == DataModelSettings.undoneLevel) {
      _itemsBox.delete(item.id);
      return;
    } else {
      var obj = SerialItem.init( item.identifier, item.target, item.translation, item.level, item.lastUse, item.phonetic);
      _itemsBox.put(item.id, obj);
    }
  }

  @override
  Statistics statistics() {
    var list = _itemsBox.values.toList();
    return Statistics(list);
  }

  List<String> asLines() {
    var buf = <String>['identifier\ttarget\ttranslation\tlevel\tlast_use\tphonetic'];

    for (var obj in _itemsBox.values) {
      var lastUse = formatter.format(obj.lastUse);
      buf.add('${obj.identifier}\t${obj.target}\t${obj.translation}\t${obj.level}\t$lastUse\t${obj.phonetic}');
    }

    return buf;
  }

  @override
  int export() {
    final lines = asLines();
    return exportLines(lines);
  }

  @override
  Future<int> import() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return Future<int>.value(0);

    List<String> lines;

    if (kIsWeb) {
      final bytes = result.files.first.bytes;
      var str = const Utf8Codec().decode(bytes!);
      lines = str.split('\n');
    } else {
      lines = await io.File(result.files.first.path!).readAsLines();
    }

    var num = _importLines(lines);

    return Future<int>.value(num);
  }

  int _importLines(List<String> lines) {
    var num = 0;
    var header = lines.first.split('\t').select((x, i) => x.trim()).toList();
    var mapper = SerialMapper(header);

    for (var line in lines.skip(1)) {
      var cell = line.split('\t').select((x, i) => x.trim()).toList();

      num++;

      var target = cell[mapper.target];
      if (!hasHebrew(target)) continue;

      var translation = cell[mapper.translation];
      var level = int.parse(cell[mapper.level]);
      var lastUse = formatter.parse(cell[mapper.lastUse]);
      var identifier = mapper.identifier < 0 ? '' : cell[mapper.identifier];
      var phonetic = mapper.phonetic < 0 ? '' : cell[mapper.phonetic];

      var obj = SerialItem.init(identifier, target, translation, level, lastUse, phonetic);
      _itemsBox.put(obj.id, obj);
    }
    return num;
  }

  @override
  Settings getSettings() {
    return _settingsBox.isEmpty
        ? Settings.init(IterationMode.random.index, DisplayMode.eng.index, true)
        : _settingsBox.get(0)!;
  }

  @override
  setSettings(Settings settings) {
    _settingsBox.put(0, settings);
  }

  @override
  int clearUnused(Iterable<Item> used) {
    var list = <String>[];
    var $set = used.select((item, _) => item.id).distinct().toSet();

    for (var id in _itemsBox.keys.ofType<String>()) {
      if (!$set.contains(id)) list.add(id);
    }

    for (var id in list) {
      _itemsBox.delete(id);
    }

    return list.length;
  }

  @override
  void reset() {
    _itemsBox.clear();
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
