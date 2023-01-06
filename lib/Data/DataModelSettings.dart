class DataModelSettings {
  static const levels = ["Again", "Good", "Easy"];

  static const valueAgain = 1;
  static const valueGood = 2;
  static const valueEasy = 3;

  static const maxLevel = 5;
  static const minExclude = 5; // how many times a used item will be excluded
  static const maxCapacity = 30; // max pool size, "again" takes 4 places, "easy" or "undone" 1 pl.
  static const undoneLevel = 0;
  static const tailLevel = -1;
  static const hiddenLevel = -2;
}
