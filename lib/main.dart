import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:mila/IO/HiveSerializer.dart';
import 'package:mila/IO/WebSource.dart';
import 'IO/ISerializer.dart';
import 'Constants.dart';
import 'Sources/SourcesView.dart';

void main() async {
  HiveSerializer.init();

  GetIt.I.registerSingleton<ISource>(WebSource());
  GetIt.I.registerLazySingleton<ISerializer>(() => HiveSerializer());

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: titleString,
      home: SourcesView(),
    );
  }
}

class AppConfig {
  static double width = 0, height = 0, blockWidth = 0, blockHeight = 0;
}
