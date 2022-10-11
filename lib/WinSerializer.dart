import 'dart:async';
import 'dart:io';
import 'package:mila/Item.dart';
import 'package:mila/WinSource.dart';
import 'package:path/path.dart' as p;
import 'package:tuple/tuple.dart';

import 'Constants.dart';
import 'ISerializer.dart';

typedef Kvp = Tuple2<String, int>;

class WinSerializer implements ISerializer {
  @override
  Stream<List<String>> loadVocabulary() async* {
    var file = p.join(WinSource.getPath(), serialName);
    var lines = WinSource.loadAsync(file);

    yield* lines;
  }

  late File _file;
  late Map<String, Kvp> _map;

  WinSerializer(List<List<String>> lines, String fpath) {
    _map = {for (var e in lines.where((i) => i.length >= 4)) e[0]: Kvp(e[1], int.parse(e[3]))};
    _file = File(fpath);
  }

  @override
  void push(Item item) {
    _map[item.he0] = Kvp(item.eng0, item.level);
    var buf = StringBuffer();

    _map.forEach((key, value) {
      buf.write(key);
      buf.write('\t');
      buf.write(value.item1);
      buf.write('\t');
      buf.write("status");
      buf.write('\t');
      buf.write(value.item2);
      buf.write('\r\n');
    });

    _file.writeAsString(buf.toString());
  }

  @override
  void sync(List<Item> items) {
    for (var item in items) {
      var kvp = _map[item.he0];
      if (kvp == null) continue;
      item.level = kvp.item2;
    }
  }
}
