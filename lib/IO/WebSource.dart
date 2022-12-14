import 'dart:async';
import '../Constants.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

import 'ISerializer.dart';

class WebSource implements ISource {
  late Document? _document;
  late List<String>? _names;

  @override
  Future<List<String>> getVocabularies() async {
    final response = await http.Client().get(Uri.parse(uri));

    _document = parser.parse(response.body);

    _names = _document!
        .getElementById('sheet-menu')!
        .getElementsByTagName('a')
        .map((e) => e.text)
        .toList();

    return Future(() => _names!);
  }

  static List<String> readRow(Element e) {
    return e.getElementsByTagName('td').map((e) => e.text).toList();
  }

  @override
  Stream<List<String>> loadComplete() async* {
    for (var name in _names!) {
      var stream = loadVocabulary(name);
      yield* stream;
    }
  }

  @override
  Stream<List<String>> loadVocabulary(String source) async* {
    var ind = _names!.indexOf(source);
    var tbody = _document!.getElementById('sheets-viewport')!.getElementsByTagName('tbody')[ind];
    var rlist = tbody.getElementsByTagName('tr');

    for (var element in rlist) {
      var cell = readRow(element);
      if (cell.length < 2) continue;
      if (cell[0].isEmpty || cell[1].isEmpty) continue;

      yield cell;
    }
  }
}