final _ws = ' '.runes.first;
final _grsh = '״'.runes.first;
final _mgph = '־'.runes.first;
final _tav = 'ת'.runes.first;
final _aleph = 'א'.runes.first;

String haserNikud(String str) {
  var runes = str
      .replaceAll('שׁ', 'ש')
      .replaceAll('שׂ', 'ש')
      .replaceAll('וּ', 'ו')
      .replaceAll('וֹ', 'ו')
      .replaceAll('אַ', 'א')
      .replaceAll('אָ', 'א')
      .runes
      .where((char) =>
          (char >= _aleph && char <= _tav) || char == _ws || char == _grsh || char == _mgph)
      .toList();

  str = String.fromCharCodes(runes);
  return str;
}

bool hasHebrew(String str) {
  return str.runes.any((char) => (char >= _aleph && char <= _tav));
}
