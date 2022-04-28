import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'DataModel.dart';
import 'Item.dart';

enum DisplayOrder { he, eng, view }

class ViewModel {
  Item? _current;
  AbstractDataModel? _model;

  RandomDataModel? _rand;
  SequentialDataModel? _seq;

  bool showNikud = false;
  bool _isComplete = true;
  DisplayOrder _displayOrder = DisplayOrder.he;

  final _ws = ' '.runes.first;
  final _tav = 'ת'.runes.first;
  final _aleph = 'א'.runes.first;

  bool get isComplete => _isComplete;

  DisplayOrder get displayOrder => _displayOrder;

  set displayOrder(DisplayOrder value) {
    _displayOrder = value;

    if (_displayOrder == DisplayOrder.view) {
      _model = _seq;
      _current = null;

      _seq!.reset();
      nextItem(0);
    } else {
      _model = _rand;
    }
  }

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
    var separator = Platform.pathSeparator;
    var envVars = Platform.environment;
    var home = envVars['UserProfile'];

    var path = home! + separator + "mila";
    var fpath = path + separator + "example.txt";
    var dir = Directory(path);

    if (!dir.existsSync()) {
      dir.createSync();
    }

    var file = File(fpath);
    if (!file.existsSync()) {}

    loadAsync(fpath).toList().then((value) => init(value, nextItem));
  }

  void init(List<List<String>> value, void Function() nextItem) {
    var items = value.map((e) => Item(e)).toList();
    var settings = DataModelSettings(4, 10, 3);

    Item.addSynonyms(items);

    _seq = SequentialDataModel(items);
    _rand = RandomDataModel(items, settings);
    _model = _rand;

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
    if (!_isComplete && _displayOrder == DisplayOrder.eng) return "";

    var str = _current!.firstString;
    if (!showNikud) str = haserNikud(str);

    return str;
  }

  // english side
  String get engSide {
    if (_current == null) return "";
    if (!_isComplete && _displayOrder == DisplayOrder.he) return "";

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

  void nextItem(int level) {
    if (_model == null) return;
    if (_current != null) {
      _model!.setLevel(_current!, level);
    }

    _isComplete = _displayOrder == DisplayOrder.view;
    _current = _model!.nextItem(_current);
  }

  Stream<List<String>> loadAsync(String fileName) async* {
    var lsp = const LineSplitter();
    final lines =
        File(fileName).openRead().transform(utf8.decoder).transform(lsp);

    await for (final line in lines) {
      final cell = line.split('\t');
      if (cell.length < 2) continue;
      if (cell[1].isEmpty) continue;

      yield cell;
    }
  }
}
