import 'DataModel.dart';

class Item {
  int level = DataModelSettings.undoneLevel;
  final List<String>? _row;

  Item(this._row);

  String get firstString {
    return _row![0];
  }

  String get secondString {
    return _row![1];
  }

  String get firstList {
    if (_row!.length < 3) return "";
    var cell = _row![2].split(' / ');

    return cell.join("\n");
  }

  set firstList(String str) {
    if (_row!.length < 3) {
      _row!.add(str);
    } else {
      _row![2] = str;
    }
  }

  String get secondList {
    if (_row!.length < 4) return "";
    var cell = _row![3].split(' / ');

    return cell.join("\n");
  }

  set secondList(String str) {
    if (_row!.length < 4) {
      _row!.add(str);
    } else {
      _row![3] = str;
    }
  }

  String get firstText {
    if (_row!.length < 5) return "";
    return _row![4];
  }

  String get secondText {
    if (_row!.length < 6) return "";
    return _row![5];
  }

  static void addSynonyms(List<Item> items) {
    var map = <String, Set<Item>>{};

    // make a set of items for each word
    for (final item in items) {
      final cell = item.secondString
          .replaceAll(";", ",")
          .split(",")
          .map((s) => s.trim())
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
    for (final item in syn.keys) {
      var iset = syn[item];
      for (final other in iset!) {
        if (item == other) continue;

        item.firstList += (' / ' + other.firstString);
        item.secondList += (' / ' + other.secondString);
      }
    }
  }
}
