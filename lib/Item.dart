import 'DataModel.dart';

class Item {
  int level = DataModelSettings.undoneLevel;
  final List<String>? _row;

  Item(this._row);

  String get firstString {
    return _row![0];
  }

  String get secondString {
    return _row![1];
  }

  String get firstList {
    if (_row!.length < 3) return "";
    var cell = _row![2].split(' / ');

    return cell.join("\n");
  }

  String get secondList {
    if (_row!.length < 4) return "";
    var cell = _row![3].split(' / ');

    return cell.join("\n");
  }

  String get firstText {
    if (_row!.length < 5) return "";
    return _row![4];
  }

  String get secondText {
    if (_row!.length < 6) return "";
    return _row![5];
  }
}
