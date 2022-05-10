import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'DataModel.dart';
import 'Item.dart';
import 'SourcesModel.dart';

enum PermanentDisplay { he, eng, view }

class VocabModel extends ChangeNotifier {
  Item? _current;

  late RandomDataModel _rand;
  late AbstractDataModel _model;
  late SequentialDataModel _seq;
  late Serializer _serializer;

  bool get showNikud => _showNikud;
  bool _showNikud = false;

  bool get isComplete => _isComplete;
  bool _isComplete = false;

  PermanentDisplay get permanentDisplay => _permanentDisplay;
  PermanentDisplay _permanentDisplay = PermanentDisplay.he;

  String get sourceName => _sourceName;
  late String _sourceName;

  final _ws = ' '.runes.first;
  final _tav = 'ת'.runes.first;
  final _aleph = 'א'.runes.first;

  VocabModel(String fileName, List<List<String>> value, Serializer serializer) {
    _sourceName = p.basename(fileName);

    var items = value.map((e) => Item(e)).toList();
    var settings = DataModelSettings(4, 16, 7);

    serializer.synch(items);
    Item.addSynonyms(items);

    _seq = SequentialDataModel(items, settings);
    _rand = RandomDataModel(items, settings);
    _model = _rand;
    _serializer = serializer;
  }

  String _haserNikud(String str) {
    var runes = str.runes.where((char) => (char >= _aleph && char <= _tav) || char == _ws).toList();
    str = String.fromCharCodes(runes);
    return str;
  }

  //---------------------------------[ properties ]---------------------------------

  String get statistics {
    var total = _model.length;
    var done = _model.where((element) => element.level == DataModelSettings.doneLevel).length;
    var undone = _model.where((element) => element.level == DataModelSettings.undoneLevel).length;
    var longMem = _model.where((element) => element.level > DataModelSettings.doneLevel).length;
    var current = total - (done + undone + longMem);

    return "$total = $undone + $current + $longMem + $done";
  }

  String get he0 {
    if (_current == null) return "";
    if (!_isComplete && _permanentDisplay == PermanentDisplay.eng) return "";

    var str = _current!.he0;
    if (!_showNikud) str = _haserNikud(str);

    return str;
  }

  String get eng0 {
    if (_current == null) return "";
    if (!_isComplete && _permanentDisplay == PermanentDisplay.he) return "";

    return _current!.eng0;
  }

  String get he1 {
    if (_current == null || !_isComplete) return "";
    return _current!.he1;
  }

  bool get hasEng1 {
    return eng1.isNotEmpty;
  }

  String get eng1 {
    if (_current == null || !_isComplete) return "";
    return _current!.eng1;
  }

  String get he2 {
    if (_current == null || !_isComplete) return "";
    return _current!.he2;
  }

  String get eng2 {
    if (_current == null || !_isComplete) return "";
    return _current!.eng2;
  }

  //---------------------------------[ commands ]---------------------------------

  void showComplete() {
    _isComplete = true;
    notifyListeners();
  }

  setShowNikud(int nikud) {
    _showNikud = (nikud == 1);
    notifyListeners();
  }

  void nextItem(int level) {
    if (_current != null) {
      _model.setLevel(_current!, level);
      _serializer.push(_current!);
    }

    _isComplete = _permanentDisplay == PermanentDisplay.view;
    _current = _model.nextItem(_current);

    notifyListeners();
  }

  void setDisplay(int value) {
    _permanentDisplay = PermanentDisplay.values[value];

    if (_permanentDisplay == PermanentDisplay.view) {
      _seq.reset();
      _model = _seq;
      _current = null;
      nextItem(0);
    } else {
      _model = _rand;
      notifyListeners();
    }
  }

  void start() {
    if (_current != null) return;
    _isComplete = _permanentDisplay == PermanentDisplay.view;
    _current = _model.nextItem(null);
  }
}
