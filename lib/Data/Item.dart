import 'package:darq/darq.dart';

import '../Library/Library.dart';
import 'DataModelSettings.dart';

class Mapper {
  late int root = -1;
  late int links = -1;
  late int target = -1;
  late int identifier = -1;
  late int phonetic = -1;
  late int translation = -1;
  late int longTarget = -1;
  late int longTranslation = -1;

  Mapper(List<String> line) {
    root = line.indexOf('root');
    links = line.indexOf('links');
    target = line.indexOf('target');
    identifier = line.indexOf('identifier');
    phonetic = line.indexOf('phonetic');
    translation = line.indexOf('translation');
    longTarget = line.indexOf('long_target');
    longTranslation = line.indexOf('long_translation');

    if (phonetic == -1) phonetic = line.indexWhere((str) => str.startsWith('pho_'));
    if (translation == -1) translation = line.indexWhere((str) => str.startsWith('tra_'));
    if (longTranslation == -1) {
      longTranslation = line.indexWhere((str) => str.startsWith('long_tra_'));
    }
  }
}

abstract class IItem {
  late int level;

  String get target;

  String get translation;
}

class Item implements IItem {
  final Set<Item> _secondary = <Item>{};

  late String _id;
  late String _haser;
  late int _complexity;

  late final Mapper _mapper;
  late final List<String> _line;

  @override
  int level = DataModelSettings.undoneLevel;
  DateTime lastUse = DateTime.now();

  String get id => _id;

  String get haser => _haser;

  int get complexity => _complexity;

  @override
  String get root => _line[_mapper.root];

  @override
  String get target => _line[_mapper.target];

  @override
  String get translation => _line[_mapper.translation];

  @override
  String get links => (_mapper.links < 0) ? '' : _line[_mapper.links];

  @override
  String get phonetic => (_mapper.phonetic < 0) ? '' : _line[_mapper.phonetic];

  @override
  String get identifier => (_mapper.identifier < 0) ? '' : _line[_mapper.identifier];

  @override
  String get longTarget => (_mapper.longTarget < 0) ? '' : _line[_mapper.longTarget];

  @override
  String get longTranslation => (_mapper.longTranslation < 0) ? '' : _line[_mapper.longTranslation];

  String get extTarget => _secondary.select((item, _) => item.target).join("\n");

  String get extTranslation => _secondary.select((item, _) => item.translation).join("\n");

  Item(this._line, this._mapper) {
    _haser = haserNikud(target);
    _id = _haser + identifier;
    _complexity = _haser.length + 5 * RegExp(r'\s').allMatches(_haser).length;
  }

  DateTime get nextUse {
    var offset = DataModelSettings.calcOffset(level);
    var next = lastUse!.add(Duration(minutes: offset));
    return next;
  }
}

Iterable<Item> fromLines(List<List<String>> lines) sync* {
  if (lines.length < 2) {
    yield* const Iterable<Item>.empty();
    return;
  }

  Mapper mapper = Mapper(lines.first);

  for (var line in lines.skip(1)) {
    var item = Item(line, mapper);
    if (hasHebrew(item.target) && item.translation.isNotEmpty) {
      yield item;
    }
  }
}

void addHomonyms(List<Item> items) {
  var map = <String, Set<Item>>{};

  for (final item in items) {
    var set = map[item.haser];
    if (set == null) {
      set = <Item>{};
      map[item.haser] = set;
    }
    set.add(item);
  }

  // make a list of synonyms for each item
  for (final set in map.values) {
    if (set.length == 1) continue;
    for (final ii in set) {
      for (final jj in set) {
        if (identical(ii, jj)) continue;
        ii._secondary.add(jj);
        jj._secondary.add(ii);
      }
    }
  }
}

Set<Set<String>> cognateRoots = {
  {'א - ו - ת', 'א - י - ת'},
  {'ק - ו - ם', 'ק - י - ם'},
  {'ח - ל - ל', 'ת - ח - ל'},
  {'כ - ו - ל', 'כ - ל - ל'},
  {'א - ס - ף', 'י - ס - ף'},
  {'ה - ו - ה', 'ה - י - ה', 'ח - י - ה', 'ח - ו - ה'},
};

void addSameRoot(List<Item> items) {
  // prepare cognate dict
  var cognate = <String, String>{};
  for (final set in cognateRoots) {
    var common = set.join(' : ');
    for (var root in set) {
      cognate[root] = common;
    }
  }

  var map = <String, Set<Item>>{};

  // make a set of items for each translation, 1:n eng->he
  for (final item in items) {
    if (item.root.isEmpty) continue;
    if (item.target.contains(",")) continue;

    final cell = item.root
        .split(",")
        .map((s) => cognate[s] ?? s)
        .where((s) => s != null && s.isNotEmpty)
        .toList();

    for (final str in cell) {
      if (str == null) continue;
      var set = map[str];
      if (set == null) {
        set = <Item>{};
        map[str] = set;
      }
      set.add(item);
    }
  }

  var syn = <Item, Set<Item>>{};

  // make a list of synonyms for each item
  for (final set in map.values) {
    if (set.length == 1) continue;
    for (final item in set) {
      var iset = syn[item];
      if (iset == null) {
        iset = <Item>{};
        syn[item] = iset;
      }
      iset.addAll(set);
    }
  }

  // add synonyms to item content
  for (final entry in syn.entries) {
    var item = entry.key;
    var iset = entry.value;

    for (final other in iset) {
      if (item != other) item._secondary.add(other);
    }
  }
}

void addSynonyms(List<Item> items) {
  var map = <String, Set<Item>>{};
  var excluded = <String>{"you"};

  // make a set of items for each translation, 1:n eng->he
  for (final item in items) {
    if (item.target.contains(",")) continue;

    final cell = item.translation
        .replaceAll(";", ",")
        .split(",")
        .map((s) => clean(s))
        .where((s) => s.isNotEmpty)
        .where((s) => !excluded.contains(s))
        .toList();

    for (final str in cell) {
      var set = map[str];
      if (set == null) {
        set = <Item>{};
        map[str] = set;
      }
      set.add(item);
    }
  }

  var syn = <Item, Set<Item>>{};

  // make a list of synonyms for each item
  for (final set in map.values) {
    if (set.length == 1) continue;
    for (final item in set) {
      var iset = syn[item];
      if (iset == null) {
        iset = <Item>{};
        syn[item] = iset;
      }
      iset.addAll(set);
    }
  }

  // add synonyms to item content
  for (final entry in syn.entries) {
    var item = entry.key;
    var iset = entry.value;

    for (final other in iset) {
      if (item != other) item._secondary.add(other);
    }
  }
}

/// verbs can start with 'to' and be
String clean(String s) {
  s = s.trim();

  if (s.startsWith('to ')) s = s.substring(3).toString();
  if (s.startsWith('be ')) s = s.substring(3).toString();

  var ind = s.indexOf('(');
  if (ind > 0) {
    s = s.substring(0, ind - 1).trim();
  }

  return s;
}

class Statistics {
  late List<IItem> total;
  late List<IItem> repeat;
  late List<IItem> done;
  late List<IItem> doneAll;
  late List<IItem> undone;
  late List<IItem> hidden;

  Statistics(List<IItem> list) {
    total = list;

    hidden = list.where((element) => element.level == DataModelSettings.hideLevel).toList();

    undone = list
        .where((element) =>
            element.level == DataModelSettings.undoneLevel ||
            element.level == DataModelSettings.skipLevel)
        .toList();

    // orange
    repeat = list
        .where((x) =>
            x.level > DataModelSettings.undoneLevel && x.level < DataModelSettings.hours3Index)
        .toList();

    // light green - between hour and day
    done = list
        .where((x) =>
            x.level >= DataModelSettings.hours3Index && x.level <= DataModelSettings.hours60Index)
        .toList();

    // dark green
    doneAll = list.where((x) => x.level > DataModelSettings.hours60Index).toList();
  }
}
