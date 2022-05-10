import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:mila/Item.dart';
import 'package:path/path.dart' as p;
import 'package:tuple/tuple.dart';

import 'VocabModel.dart';

class DirectoryModel {
  Future<List<String>> get() async {
    var envVars = Platform.environment;
    var home = envVars['UserProfile'];
    var path = p.join(home!, "mila");
    var dir = Directory(path);

    var hasDir = await dir.exists();
    if (!hasDir) {
      dir.create();
    }

    var isEmpty = await dir.list().isEmpty;
    if (isEmpty) {
      var text = await rootBundle.loadString('assets/example.txt');
      var file = File(p.join(path, "1. first words.txt"));
      file.writeAsString(text);
    }

    return dir.list().map((e) => e.path).toList();
  }
}

class FileModel {
  static Future<VocabModel> load(String fileName) async {
    var lines = await _loadAsync(fileName).toList();
    var serializer = await Serializer.load(fileName);
    return VocabModel(fileName, lines, serializer);
  }
}

typedef Kvp = Tuple2<String, int>;

class Serializer {
  static Future<Serializer> load(String fileName) async {
    var dir = p.dirname(fileName);
    var file = p.join(dir, "0. vocabulary.txt");
    var lines = await _loadAsync(file).toList();

    return Serializer(lines, file);
  }

  late File _file;
  late Map<String, Kvp> _map;

  Serializer(List<List<String>> lines, String fpath) {
    _map = {for (var e in lines.where((i) => i.length >= 4)) e[0]: Kvp(e[1], int.parse(e[3]))};
    _file = File(fpath);
  }

  void push(Item item) {
    _map[item.he0] = Kvp(item.eng0, item.level);
    var buf = StringBuffer();

    _map.forEach((key, value) {
      buf.write(key);
      buf.write('\t');
      buf.write(value.item1);
      buf.write('\t');
      buf.write("status");
      buf.write('\t');
      buf.write(value.item2);
      buf.write('\r\n');
    });

    _file.writeAsString(buf.toString());
  }

  void synch(List<Item> items) {
    for (var item in items) {
      var kvp = _map[item.he0];
      if (kvp == null) continue;
      item.level = kvp.item2;
    }
  }
}

Stream<List<String>> _loadAsync(String fileName) async* {
  var file = File(fileName);
  if (!file.existsSync()) return;

  var lsp = const LineSplitter();
  final lines = file.openRead().transform(utf8.decoder).transform(lsp);

  await for (final line in lines) {
    final cell = line.split('\t');
    if (cell.length < 2) continue;
    if (cell[0].isEmpty || cell[1].isEmpty) continue;

    yield cell;
  }
}
