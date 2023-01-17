import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../Constants.dart';
import '../IO/ISerializer.dart';
import '../Library/Widgets.dart';
import '../Page.Vocabulary/VocabView.dart';
import '../main.dart';
import 'SourceDialogs.dart';
import 'SourcesProviders.dart';

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
        child: asyncModel.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
            data: (sources) => _buildScaffold(sources, context, ref)));
  }

  Scaffold _buildScaffold(List<String> list, BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(title: const Text(titleString), actions: <Widget>[_menu(context, ref)]),
        body: _body(context, ref, list));
  }

  PopupMenuButton<int> _menu(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<int>(
      onSelected: (v) => _menuSelection(v, context, ref),
      child:
          const Padding(padding: EdgeInsets.only(right: 20.0), child: Icon(Icons.menu, size: 26)),
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<int>(
          value: 1,
          child: Text('Export vocabulary'),
        ),
        const PopupMenuItem<int>(
          value: 2,
          child: Text('Import vocabulary'),
        ),
        const PopupMenuItem<int>(
          value: 3,
          child: Text('Clear unused vocabulary'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<int>(value: 4, child: Text('Show settings')),
        const PopupMenuItem<int>(value: 5, child: Text('About')),
      ],
    );
  }

  void _menuSelection(int value, BuildContext context, WidgetRef ref) {
    var s = GetIt.I<ISerializer>();

    if (value == 1) SourceDialogs.show(context, "Exported ${s.export()} vocables");
    if (value == 2) SourceDialogs.showAsync(context, s.import());
    if (value == 3) {
      var source = GetIt.I<ISource>();
      SourceDialogs.show(context, "Cleared ${s.clearUnused(source.loadComplete())} vocables");
      ref.read(vocabularyStateProvider.notifier).update((state) => state + 1);
    }
    if (value == 4) SourceDialogs.settingsDialog(context, s);
    if (value == 5) SourceDialogs.aboutDialog(context);
  }

  Widget _body(BuildContext context, WidgetRef ref, List<String> list) {
    var serial = GetIt.I<ISerializer>();
    var stat = serial.statistics();

    ref.watch(vocabularyStateProvider);

    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Widgets.statWidget(context, stat.repeat + stat.done + stat.doneAll,
                        Icons.folder_open, Colors.black45),
                    const Expanded(child: Text("")),
                    Widgets.statWidget(context, stat.repeat, Icons.repeat, Colors.orange),
                    const Expanded(child: Text("")),
                    Widgets.statWidget(context, stat.done, Icons.done, Colors.green),
                    const Expanded(child: Text("")),
                    Widgets.statWidget(context, stat.doneAll, Icons.done_all, Colors.lightGreen),
                  ],
                ),
              ],
            ),
            Expanded(
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
                                ).then((value) => ref
                                    .read(vocabularyStateProvider.notifier)
                                    .update((state) => state + 1));
                              },
                              title: Text(
                                list[index],
                                textScaleFactor: 1.5,
                                style: const TextStyle(fontWeight: FontWeight.w300),
                              )));
                    })),
          ],
        ));
  }
}
