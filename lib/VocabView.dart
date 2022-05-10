import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'Providers.dart';
import 'SourcesModel.dart';
import 'SourcesView.dart';
import 'VocabModel.dart';

final fileResultProvider = FutureProvider<VocabModel>((ref) async {
  final fileName = ref.watch(sourceNotifierProvider);
  return FileModel.load(fileName);
});

final vocabProvider = ChangeNotifierProvider<VocabModel>((ref) {
  return ref.watch(fileResultProvider).value!;
});

class VocabView extends ConsumerWidget {
  const VocabView({Key? key}) : super(key: key);

  @override
  Widget build(context, ref) {
    final asyncModel = ref.watch(fileResultProvider);
    return Container(
        color: Colors.white,
        child: asyncModel.map(
            loading: (_) => const Center(child: CircularProgressIndicator()),
            error: (_) => Text(
                  _.error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
            data: (_) {
              return _buildScaffold(context, ref);
            }));
  }

  Scaffold _buildScaffold(BuildContext context, WidgetRef ref) {
    var model = ref.watch(vocabProvider);
    model.start();

    return Scaffold(
        appBar: AppBar(title: const Text(titleString), actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () => _settings(context, model),
                child: const Icon(
                  Icons.settings,
                  size: 26.0,
                ),
              )),
        ]),
        body: _body(ref),
        bottomNavigationBar: _buttons(ref));
  }

  void _settings(BuildContext context, VocabModel model) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Display Order:",
                          textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.w100)),
                      ToggleSwitch(
                        totalSwitches: 3,
                        labels: const ['He', 'Eng', 'View'],
                        onToggle: (index) => model.setDisplay(index!),
                        initialLabelIndex: model.permanentDisplay.index,
                      ),
                      const Text(""),
                      const Text("Show Nikud:",
                          textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.w100)),
                      ToggleSwitch(
                        fontSize: 20,
                        totalSwitches: 2,
                        labels: const ['א', 'אֲ'],
                        onToggle: (index) => model.setShowNikud(index!),
                        initialLabelIndex: model.showNikud ? 1 : 0,
                      ),
                    ],
                  )));
        });
  }

  Column _body(WidgetRef ref) {
    var model = ref.watch(vocabProvider);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(model.sourceName,
            textScaleFactor: 2, style: const TextStyle(fontWeight: FontWeight.w100)),
        Text(model.statistics,
            textScaleFactor: 2, style: const TextStyle(fontWeight: FontWeight.w100)),
        const Text(""),
        const Text(""),
        (model.permanentDisplay == PermanentDisplay.eng
            ? Text(model.eng0,
                textScaleFactor: 2, style: const TextStyle(fontWeight: FontWeight.w100))
            : Text(model.he0,
                textScaleFactor: 2,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl)),
        const Text("_________________________________"),
        (model.permanentDisplay == PermanentDisplay.eng
            ? Text(model.he0,
                textScaleFactor: 2,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl)
            : Text(model.eng0,
                textScaleFactor: 2, style: const TextStyle(fontWeight: FontWeight.w100))),
        const Text(""),
        const Text(""),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: model.hasEng1
              ? [
                  Text(model.he1, textScaleFactor: 2, textDirection: TextDirection.rtl),
                  const Text("   "),
                  Text(model.eng1,
                      textScaleFactor: 2, style: const TextStyle(fontWeight: FontWeight.w100))
                ]
              : [
                  Text(model.he1, textScaleFactor: 2, textDirection: TextDirection.rtl),
                ],
        ),
        const Text(""),
        Text(model.he2, textScaleFactor: 2, textDirection: TextDirection.rtl),
        Text(model.eng2, textScaleFactor: 2, style: const TextStyle(fontWeight: FontWeight.w100)),
      ],
    );
  }

  Widget _buttons(WidgetRef ref) {
    var model = ref.watch(vocabProvider);
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: !model.isComplete
          ? <Widget>[
              FloatingActionButton.extended(
                heroTag: 1,
                onPressed: () => model.showComplete(),
                label: const Text("           Show           "),
              )
            ]
          : <Widget>[
              FloatingActionButton(
                backgroundColor: Colors.red,
                heroTag: 2,
                onPressed: () => model.nextItem(0),
                child: const Text("Again"),
              ),
              FloatingActionButton(
                backgroundColor: Colors.orange,
                heroTag: 3,
                onPressed: () => model.nextItem(1),
                child: const Text("Hard"),
              ),
              FloatingActionButton(
                backgroundColor: Colors.lightBlueAccent,
                heroTag: 4,
                onPressed: () => model.nextItem(2),
                child: const Text("Good"),
              ),
              FloatingActionButton(
                backgroundColor: Colors.green,
                heroTag: 5,
                onPressed: () => model.nextItem(3),
                child: const Text("Easy"),
              ),
            ],
    );
  }
}
