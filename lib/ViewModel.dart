import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'DataModel.dart';
import 'Item.dart';

enum DisplayOrder { he, eng, both }

class ViewModel {
  Item? _current;
  DataModel? _model;

  bool showNikud = false;
  bool _isComplete = true;
  DisplayOrder displayOrder = DisplayOrder.he;

  final _ws = ' '.runes.first;
  final _tav = 'ת'.runes.first;
  final _aleph = 'א'.runes.first;

  get isComplete => _isComplete;

  String get statistics {
    if (_model == null) return "";
    var total = _model!.length;
    var done = _model!
        .where((element) => element.level == DataModelSettings.doneLevel)
        .length;
    var undone = _model!
        .where((element) => element.level == DataModelSettings.undoneLevel)
        .length;
    var processed = total - (done + undone);

    return "$total = $undone + $processed + $done";
  }

  ViewModel(String fileName, void Function() nextItem) {
    loadAsync(r'C:\Users\mikha\Downloads\lesson 3.tsv', 0)
        .toList()
        .then((value) => init(value, nextItem));
  }

  void init(List<List<String>> value, void Function() nextItem) {
    var items = value.map((e) => Item(e)).toList();
    var settings = DataModelSettings(4, 8, 3);
    _model = DataModel(items, settings);
    nextItem();
  }

  String haserNikud(String str) {
    var runes = str.runes
        .where((char) => (char >= _aleph && char <= _tav) || char == _ws)
        .toList();
    str = String.fromCharCodes(runes);
    return str;
  }

  // hebrew side
  String get heSide {
    if (_current == null) return "... L O A D I N G ...";
    if (!_isComplete && displayOrder == DisplayOrder.eng) return "";

    var str = _current!.firstString;
    if (!showNikud) str = haserNikud(str);

    return str;
  }

  // english side
  String get engSide {
    if (_current == null) return "";
    if (!_isComplete && displayOrder == DisplayOrder.he) return "";

    return _current!.secondString;
  }

  String get leftSide {
    if (_current == null || !_isComplete) return "";
    return _current!.firstList;
  }

  String get rightSide {
    if (_current == null || !_isComplete) return "";
    return _current!.secondList;
  }

  String get exampleFront {
    if (_current == null || !_isComplete) return "";
    return _current!.firstText;
  }

  String get exampleBack {
    if (_current == null || !_isComplete) return "";
    return _current!.secondText;
  }

  void showComplete() {
    _isComplete = true;
  }

  void nextGuess(int level) {
    if (_model == null) return;
    if (_current != null) {
      _model!.setLevel(_current!, level);
    }

    _isComplete = displayOrder == DisplayOrder.both;
    _current = _model!.nextGuess(_current);
  }

  Stream<List<String>> loadAsync(String fileName, int skipCol) async* {
    var lsp = const LineSplitter();
    final lines =
        File(fileName).openRead().transform(utf8.decoder).transform(lsp);

    await for (final line in lines) {
      final cell = line.split('\t');
      if (cell.length < 2) continue;
      if (cell[1].isEmpty) continue;

      yield cell.skip(skipCol).toList();
    }
  }
}
