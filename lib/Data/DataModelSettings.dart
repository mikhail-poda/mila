import 'package:flutter/material.dart';

enum Level implements Comparable<Level> {
  again(level: 1, text: "again", color: Colors.orange),
  good(level: 2, text: "good", color: Colors.lightBlueAccent),
  easy(level: 3, text: "easy", color: Colors.green);

  const Level({
    required this.level,
    required this.text,
    required this.color,
  });

  final int level;
  final String text;
  final Color? color;

  @override
  int compareTo(Level other) => index - other.index;
}

class DataModelSettings {
  static const maxLevel = 4;
  static const minExclude = 7; // how many times a used item will be excluded from draw
  static const maxCapacity = 20; // max pool size, "again" takes 4 places, "easy" or "undone" 1 pl.

  // not considered
  static const undoneLevel = 0;
  static const tailLevel = -1;
  static const hiddenLevel = -2;
}
