import 'dart:math';

import 'package:darq/darq.dart';
import 'package:collection/collection.dart' show IterableZip;

import '../Library/Library.dart';
import 'DataModelSettings.dart';

class Mapper {
  late int target = -1;
  late int identifier = -1;
  late int phonetic = -1;
  late int translation = -1;
  late int addTarget = -1;
  late int addTranslation = -1;
  late int longTarget = -1;
  late int longTranslation = -1;

  Mapper(List<String> line) {
    target = line.indexOf('target');
    identifier = line.indexOf('identifier');
    phonetic = line.indexOf('phonetic');
    translation = line.indexOf('translation');
    addTarget = line.indexOf('add_target');
    addTranslation = line.indexOf('add_translation');
    longTarget = line.indexOf('long_target');
    longTranslation = line.indexOf('long_translation');

    if (phonetic == -1) phonetic = line.indexWhere((str) => str.startsWith('pho_'));
    if (translation == -1) translation = line.indexWhere((str) => str.startsWith('tra_'));
    if (addTranslation == -1) addTranslation = line.indexWhere((str) => str.startsWith('add_tra_'));
    if (longTranslation == -1)
      longTranslation = line.indexWhere((str) => str.startsWith('long_tra_'));
  }
}

abstract class Item {
  final Set<Item> _secondary = <Item>{};

  late String _id;

  int level = DataModelSettings.undoneLevel;
  DateTime lastUse = DateTime.now();

  String get id => _id;

  String get target;

  String get translation;

  String get identifier;

  String get phonetic => '';

  String get addTarget => _secondary.select((item, _) => item.target).join("\n");

  String get addTranslation => _secondary.select((item, _) => item.translation).join("\n");

  String get longTarget => '';

  String get longTranslation => '';

  Item() {
    _id = haserNikud(target) + identifier;
  }

  DateTime get nextUse {
    var diff = level - DataModelSettings.maxLevel;
    if (diff < 0) return lastUse;

    var days = pow(2, diff) as int;
    var next = lastUse!.add(Duration(days: days));
    return next;
  }
}

class AdditionalItem extends Item {
  late final String _identifier;
  late final String _target;
  late final String _translation;
  late final String _phonetic;

  @override
  String get identifier => _identifier;

  @override
  String get target => _target;

  @override
  String get translation => _translation;

  @override
  String get phonetic => _phonetic;

  AdditionalItem(this._identifier, this._target, this._translation, this._phonetic) : super();
}

class TextItem extends Item {
  late final Mapper _mapper;
  late final List<String> _line;

  TextItem(this._line, this._mapper) : super();

  @override
  String get target => _line[_mapper.target];

  @override
  String get translation => _line[_mapper.translation];

  @override
  String get phonetic => (_mapper.phonetic < 0) ? '' : _line[_mapper.phonetic];

  @override
  String get identifier => (_mapper.identifier < 0) ? '' : _line[_mapper.identifier];

  @override
  String get addTarget => _secondary.isNotEmpty
      ? super.addTarget
      : (_mapper.addTarget < 0)
          ? ''
          : _line[_mapper.addTarget];

  @override
  String get addTranslation => _secondary.isNotEmpty
      ? super.addTranslation
      : (_mapper.addTranslation < 0)
          ? ''
          : _line[_mapper.addTranslation];

  @override
  String get longTarget => (_mapper.longTarget < 0) ? '' : _line[_mapper.longTarget];

  @override
  String get longTranslation => (_mapper.longTranslation < 0) ? '' : _line[_mapper.longTranslation];
}

Iterable<Item> fromLines(List<List<String>> lines) sync* {
  if (lines.length < 2) {
    yield* const Iterable<Item>.empty();
    return;
  }

  Mapper mapper = Mapper(lines.first);

  for (var line in lines.skip(1)) {
    var item = TextItem(line, mapper);
    if (hasHebrew(item.target) && item.translation.isNotEmpty) {
      yield item;
    }
  }
}

void addSecondary(List<Item> items) {
  var map = items.toMap((e) => MapEntry(e.id, e), modifiable: true);

  for (var item in items.toList()) {
    var addTarget = item.addTarget.trim();
    var addTranslation = item.addTranslation.trim();

    if (addTarget.isEmpty) continue;
    if (addTranslation.isEmpty) addTranslation = item.translation;

    var targetList = addTarget.split('/');
    var translationList = addTranslation.split('/');

    if (targetList.length == 1 && targetList[0].contains(',')) {
      targetList = targetList[0].split(',');
    }

    if (translationList.length == 1 && targetList.length > 1) {
      translationList = List.filled(targetList.length, translationList[0]);
    }

    var secondary = IterableZip([targetList, translationList]);

    for (var entry in secondary) {
      var he = haserNikud(entry[0]).trim();
      var other = map[he];
      if (other == null) {
        other = AdditionalItem('', entry[0].trim(), entry[1].trim(), '');
        map[he] = other;
        items.add(other);
      }

      item._secondary.add(other);
      other._secondary.add(item);
    }
  }
}

void addSynonyms(List<Item> items) {
  var map = <String, Set<Item>>{};

  // make a set of items for each word
  for (final item in items) {
    final cell = item.translation.replaceAll(";", ",").split(",").map((s) => clean(s)).toList();

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

  // mak a list of synonyms for each item
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

/// verbs can start with 'to' and
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
