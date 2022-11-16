import 'package:darq/darq.dart';
import 'package:mila/Item.dart';

import 'Library.dart';

class Result<V, E> {
  final V? value;
  final E? error;

  bool get hasValue => value != null;

  bool get hasError => error != null;

  Result.value(this.value) : error = null;

  Result.error(this.error) : value = null;
}

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
      var key = haserNikud(item.he0);
      if (hmap.containsKey(key)) {
        var master = hmap[key]!;
        if (!repetitions.contains(master)) repetitions.add(master);
        repetitions.add(item);
      } else {
        hmap[key] = item;
      }
    }

    var num = repetitions
        .distinct((e) => haserNikud(e.he0))
        .length;
    if (num == 0) return null;

    var msg = 'Error: $num repetitions found.';
    var dsc = repetitions.select((i, j) => '${i.he0}   ${i.eng0}').join('\n');

    return SourceError(name, items.length, msg, dsc);
  }
}
