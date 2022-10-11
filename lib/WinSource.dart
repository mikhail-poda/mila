import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import 'ISerializer.dart';

class WinSource implements ISource {
  @override
  Future<List<String>> getVocabularies() async {
    final path = getPath();
    final dir = Directory(path);

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

  static String getPath() {
    var envVars = Platform.environment;
    var home = envVars['UserProfile'];
    var path = p.join(home!, "mila");
    return path;
  }

  @override
  Stream<List<String>> loadVocabulary(String fileName) async* {
    yield* loadAsync(fileName);
  }

  static Stream<List<String>> loadAsync(String fileName) async* {
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
}
