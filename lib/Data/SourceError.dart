import 'package:darq/darq.dart';

import 'Item.dart';

class SourceError {
  final String name;
  final int length;
  final String message;
  final String description;

  SourceError(this.name, this.length, this.message, this.description);

  static SourceError? any(String name, List<Item> items) {
    if (items.isEmpty) {
      return SourceError(name, 0, "No elements", "");
    }

    var hmap = <String, Item>{};
    var repetitions = <Item>[];

    for (var item in items) {
      var key = item.id;
      if (hmap.containsKey(key)) {
        var master = hmap[key]!;
        if (!repetitions.contains(master)) repetitions.add(master);
        repetitions.add(item);
      } else {
        hmap[key] = item;
      }
    }

    var num = repetitions.distinct((e) => e.id).length;
    if (num != 0) {
      var msg = 'Error: $num repetitions found.';
      var dsc = repetitions.select((i, j) => '${i.target}   ${i.translation}').join('\n');

      return SourceError(name, items.length, msg, dsc);
    }

    var commas = items.where((element) => element.target.contains(',')).toList();
    if (commas.isNotEmpty) {
      var msg = 'Error: ${commas.length} entries contain commas.';
      var dsc = commas.select((i, j) => '${i.target}   ${i.translation}').join('\n');

      return SourceError(name, items.length, msg, dsc);
    }

    return null;
  }
}