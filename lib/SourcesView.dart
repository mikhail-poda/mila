import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:mila/ISerializer.dart';

import 'Constants.dart';
import 'VocabView.dart';
import 'main.dart';

final vocabulariesListProvider = FutureProvider<List<String>>((ref) async => getVocabularies());
final vocabularyNameProvider = StateProvider<String>((ref) => "");

Future<List<String>> getVocabularies() async {
  var list0 = await GetIt.I<ISource>().getVocabularies();
  var list1 = list0.toList(); // add new item to a new list

  list1.insert(0, serialName);
  return list1;
}

class SourcesView extends ConsumerWidget {
  const SourcesView({Key? key}) : super(key: key);

  @override
  Widget build(context, ref) {
    final asyncModel = ref.watch(vocabulariesListProvider);

    AppConfig.width = MediaQuery.of(context).size.width;
    AppConfig.height = MediaQuery.of(context).size.height;
    AppConfig.blockWidth = AppConfig.width / 100;
    AppConfig.blockHeight = AppConfig.height / 100;

    return Container(
        color: Colors.white,
        child: asyncModel.map(
            loading: (_) => const Center(child: CircularProgressIndicator()),
            error: (_) => Text(
                  _.error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
            data: (_) => _buildScaffold(_.value, ref)));
  }

  Scaffold _buildScaffold(List<String> list, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(titleString),
        ),
        body: Center(
            child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: list.length,
                itemBuilder: (BuildContext context, int index) {
                  return Material(
                      child: ListTile(
                          onTap: () {
                            ref.read(vocabularyNameProvider.notifier).state = list[index];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => const VocabView(),
                              ),
                            );
                          },
                          title: Text(
                            list[index],
                            textScaleFactor: 1.5,
                            style: const TextStyle(fontWeight: FontWeight.w300),
                          )));
                })));
  }
}
