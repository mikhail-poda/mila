import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'PlatformSwitch.dart';
import 'Providers.dart';
import 'VocabView.dart';

final directoryResultProvider = FutureProvider<List<String>>((ref) async => PlatformSwitch.getVocabularies());

final sourceNotifierProvider = StateProvider<String>((ref) => "");

class SourcesView extends ConsumerWidget {
  const SourcesView({Key? key}) : super(key: key);

  @override
  Widget build(context, ref) {
    final asyncModel = ref.watch(directoryResultProvider);

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
                            ref.read(sourceNotifierProvider.notifier).state = list[index];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => const VocabView(),
                              ),
                            );
                          },
                          title: Text(list[index])));
                })));
  }
}
