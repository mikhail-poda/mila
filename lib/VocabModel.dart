import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'DataModel.dart';
import 'Item.dart';
import 'SourcesModel.dart';

enum GuessMode { he, eng }
enum IterationMode { sequential, random }
enum DisplayMode { he, eng, random, complete }

class VocabModel extends ChangeNotifier {
  Item? _current;
  final _random = Random();

  late AbstractDataModel _model;
  late Serializer _serializer;

  bool get showNikud => _showNikud;
  bool _showNikud = false;

  // transaction
  bool get isComplete => _isComplete;
  bool _isComplete = false;

  // transaction
  GuessMode get guessMode => _guessMode;
  GuessMode _guessMode = GuessMode.he;

  // settings
  DisplayMode get displayMode => _displayMode;
  DisplayMode _displayMode = DisplayMode.he;

  // settings
  IterationMode get iterationMode => _iterationMode;
  IterationMode _iterationMode = IterationMode.random;

  String get sourceName => _sourceName;
  late String _sourceName;

  final _ws = ' '.runes.first;
  final _tav = 'ת'.runes.first;
  final _aleph = 'א'.runes.first;

  late List<Item> _items;
  final DataModelSettings _settings = DataModelSettings(4, 16, 3);

  bool _showHe = false;
  bool _showEng = false;

  VocabModel(String fileName, List<List<String>> value, Serializer serializer) {
    _sourceName = p.basename(fileName);
    _items = value.map((e) => Item(e)).toList();

    serializer.synch(_items);
    Item.addSynonyms(_items);

    setIterationMode(_iterationMode.index);
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
    if (!_showHe || _current == null) return "";

    var str = _current!.he0;
    if (!_showNikud) str = _haserNikud(str);

    return str;
  }

  String get eng0 {
    if (!_showEng || _current == null) return "";

    return _current!.eng0;
  }

  String get he1 {
    if (!_isComplete || _current == null) return "";
    return _current!.he1;
  }

  bool get hasEng1 {
    return eng1.isNotEmpty;
  }

  String get eng1 {
    if (!_isComplete || _current == null) return "";
    return _current!.eng1;
  }

  String get he2 {
    if (!_isComplete || _current == null) return "";
    return _current!.he2;
  }

  String get eng2 {
    if (!_isComplete || _current == null) return "";
    return _current!.eng2;
  }

  //---------------------------------[ commands ]---------------------------------

  /// On button press 'Show'
  void showComplete() {
    _prepareTransaction(true);
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

    _current = _model.nextItem(_current);
    _prepareTransaction(false);
    notifyListeners();
  }

  void setIterationMode(int value) {
    _iterationMode = IterationMode.values[value];

    if (_iterationMode == IterationMode.sequential) {
      _model = SequentialDataModel(_items, _settings);
    } else {
      _model = RandomDataModel(_items, _settings);
    }
  }

  void setDisplayMode(int value) {
    _displayMode = DisplayMode.values[value];
    _prepareTransaction(_isComplete);
    notifyListeners();
  }

  void start() {
    if (_current != null) return;
    _current = _model.nextItem(null);
    _prepareTransaction(false);
  }

  void _prepareTransaction(bool isComplete) {
    _isComplete = isComplete || _displayMode == DisplayMode.complete;
    if (!_isComplete) {
      switch (_displayMode) {
        case DisplayMode.he:
          _guessMode = GuessMode.he;
          break;
        case DisplayMode.eng:
          _guessMode = GuessMode.eng;
          break;
        case DisplayMode.random:
          _guessMode = GuessMode.values[_random.nextInt(2)];
          break;
      }

      _showHe = _guessMode == GuessMode.he;
      _showEng = _guessMode == GuessMode.eng;
    } else {
      _showHe = true;
      _showEng = true;
    }
  }
}
