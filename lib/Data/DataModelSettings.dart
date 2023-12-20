import 'dart:math';

import 'package:flutter/material.dart';

enum Skill {
  again(text: "again", color: Colors.orange),
  good(text: "good", color: Colors.lightBlueAccent),
  easy(text: "easy", color: Colors.green);

  const Skill({
    required this.text,
    required this.color,
  });

  final String text;
  final Color? color;
}

class DataModelSettings {
  static const waitQueueWidth = 4; // how many times a used item will be excluded from draw

  // not considered
  static const startLevel = 1;
  static const undoneLevel = 0;
  static const skipLevel = -1;
  static const hideLevel = -2;

  // approximate indices
  static const minutes21Index = 6;
  static const hours3Index = 10;
  static const hours60Index = 16;
  static const yearIndex = 26;

  static int calcOffset(int level) {
    return pow(1.67, level).toInt();
  }
}
