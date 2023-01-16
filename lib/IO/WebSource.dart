import 'dart:async';
import 'package:darq/darq.dart';

import '../Constants.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

import '../Data/Item.dart';
import 'ISerializer.dart';

class WebSource implements ISource {
  late Document? _document;
  late List<String>? _names;

  @override
  Stream<String> getVocabularies() async* {
    final response = await http.Client().get(Uri.parse(uri));

    _document = parser.parse(response.body);

    _names = _document!
        .getElementById('sheet-menu')!
        .getElementsByTagName('a')
        .map((e) => e.text)
        .toList();

    yield* _names!.where((e) => !e.startsWith('.')).toStream();
  }

  static List<String> readRow(Element e) {
    return e.getElementsByTagName('td').map((e) => e.text.trim()).toList();
  }

  @override
  Iterable<Item> loadComplete() sync* {
    for (var name in _names!) {
      var stream = loadVocabulary(name);
      yield* stream;
    }
  }

  @override
  Iterable<Item> loadVocabulary(String source) sync* {
    var ind = _names!.indexOf(source);
    var tbody = _document!.getElementById('sheets-viewport')!.getElementsByTagName('tbody')[ind];
    var rlist = tbody.getElementsByTagName('tr');

    var lines = geRows(rlist).toList();
    yield* fromLines(lines);
  }

  Iterable<List<String>> geRows(List<Element> rlist) sync* {
    for (var element in rlist) {
      var cell = readRow(element);
      if (cell.length >= 2) yield cell;
    }
  }
}
