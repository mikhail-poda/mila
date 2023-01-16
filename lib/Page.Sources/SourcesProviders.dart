import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../IO/ISerializer.dart';

final vocabulariesListProvider = FutureProvider<List<String>>(
    (ref) async => await GetIt.I<ISource>().getVocabularies().toList());

final vocabularyNameProvider = StateProvider<String>((ref) => "");