import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../Constants.dart';
import '../IO/ISerializer.dart';
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
        child: asyncModel.map(
            loading: (_) => const Center(child: CircularProgressIndicator()),
            error: (_) => Text(
                  _.error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
            data: (_) => _buildScaffold(_.value, context, ref)));
  }

  Scaffold _buildScaffold(List<String> list, BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(title: const Text(titleString), actions: <Widget>[_menu(context)]),
        body: _body(list, ref));
  }

  PopupMenuButton<int> _menu(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: (v) => _menuSelection(v, context),
      child:
      const Padding(padding: EdgeInsets.only(right: 20.0), child: Icon(Icons.menu, size: 26)),
      itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
        const PopupMenuItem<int>(
          value: 1,
          child: Text('Export vocabulary'),
        ),
        const PopupMenuItem<int>(
          value: 2,
          child: Text('Import vocabulary'),
        ),
        const PopupMenuItem<int>(value: 3, child: Text('Show settings')),
        const PopupMenuItem<int>(value: 4, child: Text('About')),
      ],
    );
  }

  void _menuSelection(int value, BuildContext context) {
    if (value == 1) SourceDialogs.exported(context, GetIt.I<ISerializer>().export());
    if (value == 2) SourceDialogs.imported(context, GetIt.I<ISerializer>().import());
    if (value == 3) SourceDialogs.settingsDialog(context, GetIt.I<ISerializer>());
    if (value == 4) SourceDialogs.aboutDialog(context);
  }

  Center _body(List<String> list, WidgetRef ref) {
    return Center(
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
            }));
  }
}
