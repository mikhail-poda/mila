import 'package:darq/darq.dart';
import 'package:collection/collection.dart' show IterableZip;

import '../Library/Library.dart';
import 'DataModelSettings.dart';

class Item {
  DateTime? lastUse;
  int level = DataModelSettings.undoneLevel;

  final List<String> _row;
  final Set<Item> _secondary = <Item>{};
  late String Id;

  Item(this._row) {
    Id = haserNikud(he0);
  }

  String get he0 => _row[0];

  String get eng0 => _row[1];

  String get he1 => _secondary.select((item, _) => item.he0).join("\n");

  String get eng1 => _secondary.select((item, _) => item.eng0).join("\n");

  String get he2 => (_row.length < 5) ? "" : _row[4];

  String get eng2 => (_row.length < 6) ? "" : _row[5];

  String get heng0 => (_row.length < 7) ? "" : _row[6];

  static void addSecondary(List<Item> items) {
    var map = items.toMap((e) => MapEntry(e.Id, e), modifiable: true);

    for (var item in items.toList()) {
      if (item._row.length < 4) continue;

      var row2 = item._row[2].trim();
      var row3 = item._row[3].trim();

      if (row2.isEmpty) continue;
      if (row3.isEmpty) row3 = item.eng0;

      var heList = row2.split('/');
      var engList = row3.split('/');

      if (heList.length == 1 && heList[0].contains(',')) {
        heList = heList[0].split(',');
      }

      if (engList.length == 1 && heList.length > 1) {
        engList = List.filled(heList.length, engList[0]);
      }

      var secondary = IterableZip([heList, engList]);

      for (var entry in secondary) {
        var he = haserNikud(entry[0]).trim();
        var other = map[he];
        if (other == null) {
          other = Item(<String>[entry[0].trim(), entry[1].trim()]);
          map[he] = other;
          items.add(other);
        }

        item._secondary.add(other);
        other._secondary.add(item);
      }
    }
  }

  static void addSynonyms(List<Item> items) {
    var map = <String, Set<Item>>{};

    // make a set of items for each word
    for (final item in items) {
      final cell = item.eng0.replaceAll(";", ",").split(",").map((s) => clean(s)).toList();

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
  static String clean(String s) {
    s = s.trim();

    if (s.startsWith('to ')) s = s.substring(3).toString();
    if (s.startsWith('be ')) s = s.substring(3).toString();

    var ind = s.indexOf('(');
    if (ind > 0) {
      s = s.substring(0, ind - 1).trim();
    }

    return s;
  }

  static Iterable<Item> makeUnique(List<Item> items) sync* {
    var set = <String>{};
    for (var item in items) {
      if (set.contains(item.Id)) continue;
      set.add(item.Id);
      yield item;
    }
  }
}
