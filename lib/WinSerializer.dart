import 'dart:async';
import 'dart:io';
import 'package:mila/Item.dart';
import 'package:mila/WinSource.dart';
import 'package:path/path.dart' as p;
import 'package:tuple/tuple.dart';

import 'ISerializer.dart';

typedef Kvp = Tuple2<String, int>;

class WinSerializer implements ISerializer {

  static Future<ISerializer> load(String dirName) async {
    var file = p.join(dirName, "0. vocabulary.txt");
    var lines = await WinSource.loadAsync(file).toList();

    return WinSerializer(lines, file);
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
