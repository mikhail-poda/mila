import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../Data/AbstractDataModel.dart';
import '../Data/DataModelSettings.dart';
import '../Data/RandomDataModel.dart';
import '../Data/SequentialDataModel.dart';
import '../IO/ISerializer.dart';
import '../IO/Settings.dart';
import '../Data/Item.dart';
import '../Library/Library.dart';

enum GuessMode { he, eng }

class VocabModel extends ChangeNotifier {
  Item? _current;
  final _random = Random();

  final _stack = <Item>[];

  late Settings _settings;
  late ISerializer _serializer;
  late AbstractDataModel _model;

  // transaction
  bool get isComplete => _isComplete;
  bool _isComplete = false;

  // transaction
  GuessMode get guessMode => _guessMode;
  GuessMode _guessMode = GuessMode.he;

  String get sourceName => _sourceName;
  late String _sourceName;

  late List<Item> _items;

  bool _showHe = false;
  bool _showEng = false;

  bool get hasPrevious => _stack.isNotEmpty;

  bool get hasItem => _current != null;

  Item? get currentItem => _current;

  VocabModel(String sourceName, List<Item> items, ISerializer serializer) {
    _sourceName = p.basename(sourceName);
    _settings = serializer.getSettings();
    _items = items;

    serializer.sync(_items);

    if (_settings.iterationMode == IterationMode.sequential) {
      _model = SequentialDataModel(_items);
    } else {
      _model = RandomDataModel(_items);
    }

    _serializer = serializer;
  }

  //---------------------------------[ properties ]---------------------------------

  int get length => _model.length;

  int? get pendingNo => _model.pendingNo;

  List<Item> get count1 =>
      _model.where((element) => element.level == DataModelSettings.hiddenLevel).toList();

  List<Item> get count2 => _model
      .where((element) =>
          (element.level == DataModelSettings.undoneLevel) ||
          (element.level == DataModelSettings.tailLevel))
      .toList();

  List<Item> get count3 => _model
      .where((element) =>
          (element.level > DataModelSettings.undoneLevel) &&
          (element.level < DataModelSettings.maxLevel))
      .toList();

  List<Item> get count4 =>
      _model.where((element) => element.level == DataModelSettings.maxLevel).toList();

  List<Item> get count5 =>
      _model.where((element) => element.level > DataModelSettings.maxLevel).toList();

  String get he0 {
    if (!_showHe || _current == null) return "";

    var str = _current!.target;
    if (!_settings.showNikud) str = haserNikud(str);

    return str;
  }

  String get eng0 {
    if (!_showEng || _current == null) return "";

    return _current!.translation;
  }

  String get he1 {
    if (!_isComplete || _current == null) return "";
    return _current!.addTarget;
  }

  bool get hasEng1 {
    return eng1.isNotEmpty;
  }

  String get eng1 {
    if (!_isComplete || _current == null) return "";
    return _current!.addTranslation;
  }

  String get he2 {
    if (!_isComplete || _current == null) return "";
    return _current!.longTarget;
  }

  String get eng2 {
    if (!_isComplete || _current == null) return "";
    return _current!.longTranslation;
  }

  String get phonetic {
    if (!_isComplete || _current == null) return "";
    return _current!.phonetic;
  }

  //---------------------------------[ commands ]---------------------------------

  /// On button press 'Show'
  void showComplete() {
    _prepareTransaction(true);
    notifyListeners();
  }

  void nextItem(int value) {
    if (_current != null) {
      _model.setLevel(_current!, value);
      _serializer.push(_current!);

      if (_current!.level != DataModelSettings.undoneLevel) {
        _stack.add(_current!);
      }
    }

    _current = _model.nextItem(_current);
    _prepareTransaction(false);
    notifyListeners();
  }

  void prevItem() {
    var item = _stack.isNotEmpty ? _stack.removeLast() : null;
    if (item == null || item == _current) return;

    _current = item;
    _prepareTransaction(false);
    notifyListeners();
  }

  void initialize() {
    if (_current != null) return;
    _current = _model.nextItem(null);
    _prepareTransaction(false);
  }

  void _prepareTransaction(bool isComplete) {
    _isComplete = isComplete || _settings.displayMode == DisplayMode.complete;

    if (!_isComplete) {
      switch (_settings.displayMode) {
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

  void resetItems(bool Function(Item) func) {
    var items = _model.resetItems(func);
    for (var item in items) {
      _serializer.push(item!);
    }
    notifyListeners();
  }
}
