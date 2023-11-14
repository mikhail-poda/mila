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
  static const waitQueueWidth = 5; // how many times a used item will be excluded from draw

  // not considered
  static const startLevel = 1;
  static const undoneLevel = 0;
  static const skipLevel = -1;
  static const hideLevel = -2;

  // approximate indices
  static const min10Index = 6;
  static const hourIndex = 10;
  static const dayIndex = 17;

  static const fibonacci = [
    0,
    1,
    1,
    2,
    3,
    5,
    8,
    13,
    21,
    34,
    55,
    89,
    144,
    233,
    377,
    610,
    987,
    1597,
    2584,
    4181,
    6765,
    10946,
    17711,
    28657,
    46368,
    75025,
    121393,
    196418,
    317811,
    514229
  ];
}
