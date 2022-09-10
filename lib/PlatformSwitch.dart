import 'dart:io';
import 'package:flutter/services.dart';
import 'package:mila/ISerializer.dart';
import 'package:mila/Item.dart';
import 'PlatformWin.dart';

import 'package:path/path.dart' as p;

class PlatformSwitch {
  static Future<List<String>> getVocabularies() async {
    if (Platform.isWindows) {
      return PlatformWin.getVocabularies();
    } else {
      throw PlatformException(code: "Not supported platform");
    }
  }

  static Future<List<Item>> getItems(String fileName) async {
    if (Platform.isWindows) {
      final lines = await PlatformWin.loadAsync(fileName).toList();
      return lines.map((e) => Item(e)).toList();
    } else {
      throw PlatformException(code: "Not supported platform");
    }
  }

  static Future<ISerializer> getSerializer(String fileName) async {
    if (Platform.isWindows) {
      final dirName = p.dirname(fileName);
      return await SerializerWin.load(dirName);
    } else {
      throw PlatformException(code: "Not supported platform");
    }
  }
}
