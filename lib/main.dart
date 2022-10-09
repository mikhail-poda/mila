import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:mila/WebSerializer.dart';
import 'package:mila/WebSource.dart';
import 'ISerializer.dart';
import 'Constants.dart';
import 'SourcesView.dart';

void main() async {
  WebSerializer.init();

  GetIt.I.registerSingleton<ISource>(WebSource());
  GetIt.I.registerLazySingleton<ISerializer>(() => WebSerializer());

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
