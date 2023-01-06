import 'package:hive/hive.dart';

part 'Settings.g.dart';

enum IterationMode { sequential, random }

enum DisplayMode { he, eng, random, complete }

@HiveType(typeId: 2)
class Settings{

  @HiveField(0)
  late IterationMode iterationMode;

  @HiveField(1)
  late DisplayMode displayMode;

  @HiveField(2)
  late bool showNikud;

  Settings();

  Settings.init(this.iterationMode, this.displayMode, this.showNikud);
}
