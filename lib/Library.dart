final _ws = ' '.runes.first;
final _tav = 'ת'.runes.first;
final _aleph = 'א'.runes.first;

String haserNikud(String str) {
  var runes = str.runes.where((char) => (char >= _aleph && char <= _tav) || char == _ws).toList();
  str = String.fromCharCodes(runes);
  return str;
}
