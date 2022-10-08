import 'package:mila/ISerializer.dart';
import 'package:mila/Item.dart';
import 'WebSource.dart';
import 'WinSource.dart';

import 'package:path/path.dart' as p;
//import 'package:flutter/foundation.dart' show kIsWeb;

/*
class PlatformSwitch {
  static const kIsWeb = true;

  static Future<List<String>> getVocabularies() async {
    if (kIsWeb) {
      return PlatformWeb.getVocabularies();
    } else {
      return PlatformWin.getVocabularies();
    }
  }

  static Future<List<Item>> getItems(String fileName) async {
    if (kIsWeb) {
      final lines = await PlatformWeb.loadAsync(fileName);
      return lines.map((e) => Item(e)).toList();
    } else {
      final lines = await PlatformWin.loadAsync(fileName);
      return lines.map((e) => Item(e)).toList();
    }
  }

  static Future<ISerializer> getSerializer(String fileName) async {
    if (kIsWeb) {
      return await SerializerWeb();
    } else {
      final dirName = p.dirname(fileName);
      return await SerializerWin.load(dirName);
    }
  }
}
 */
