import 'package:darq/darq.dart';
import 'package:collection/collection.dart' show IterableZip;

import 'DataModel.dart';
import 'Library.dart';

class Item {
  DateTime? lastUse;
  int level = DataModelSettings.undoneLevel;

  final List<String> _row;
  final Set<Item> _secondary = <Item>{};

  Item(this._row);

  String get he0 {
    return _row[0];
  }

  String get eng0 {
    return _row[1];
  }

  String get he1 {
    return _secondary.select((item, _) => item.he0).join("\n");
  }

  String get eng1 {
    return _secondary.select((item, _) => item.eng0).join("\n");
  }

  String get he2 {
    if (_row.length < 5) return "";
    return _row[4];
  }

  String get eng2 {
    if (_row.length < 6) return "";
    return _row[5];
  }

  static void addSecondary(List<Item> items) {
    var map = items.toMap((e) => MapEntry(haserNikud(e.he0), e), modifiable: true);

    for (var item in items.toList()) {
      if (item._row.length < 4) continue;

      var heList = item._row[2].split(' / ');
      var engList = item._row[3].split(' / ');
      var secondary = IterableZip([heList, engList]);

      for (var entry in secondary) {
        var he = haserNikud(entry[0]);
        var other = map[he];
        if (other == null) {
          other = Item(<String>[entry[0], entry[1]]);
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
      final cell = item.eng0.replaceAll(";", ",").split(",").map((s) => s.trim()).toList();

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
}
