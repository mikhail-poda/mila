import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:mila/ISerializer.dart';
import 'package:mila/Item.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'SourcesView.dart';
import 'VocabModel.dart';
import 'main.dart';

final fileResultProvider = FutureProvider<VocabModel>((ref) async {
  final source = ref.watch(vocabularyNameProvider);

  var lines = GetIt.I<ISource>().loadVocabulary(source);
  final items = await lines.map((e) => Item(e)).toList();
  final serializer = GetIt.I<ISerializer>();

  return VocabModel(source, items, serializer);
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
        appBar: AppBar(title: Text('${model.sourceName} 〈${model.length}〉'), actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () => _settings(context, model),
                child: const Icon(
                  Icons.menu,
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
                      const Text("Iteration Order:",
                          textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.w100)),
                      ToggleSwitch(
                        totalSwitches: 2,
                        labels: const ['Sequential', 'Random'],
                        onToggle: (index) => model.setIterationMode(index!),
                        initialLabelIndex: model.iterationMode.index,
                      ),
                      const Text(""),
                      const Text("Display Order:",
                          textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.w100)),
                      ToggleSwitch(
                        totalSwitches: 4,
                        labels: const ['He', 'Eng', 'Random', 'Both'],
                        onToggle: (index) => model.setDisplayMode(index!),
                        initialLabelIndex: model.displayMode.index,
                      ),
                      const Text(""),
                      const Text("Show Nikud:",
                          textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.w100)),
                      ToggleSwitch(
                        totalSwitches: 2,
                        labels: const ['א', '∵'],
                        onToggle: (index) => model.setShowNikud(index!),
                        initialLabelIndex: model.showNikud ? 1 : 0,
                      ),
                    ],
                  )));
        });
  }

  Widget _body(WidgetRef ref) {
    var model = ref.watch(vocabProvider);
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                showStat(model.count1, Icons.do_disturb_on_outlined, Colors.black38),
                const Expanded(child: Text("")),
                showStat(model.count2, Icons.hourglass_empty_sharp, Colors.black45),
                const Expanded(child: Text("")),
                showStat(model.count3, Icons.repeat, Colors.orange),
                const Expanded(child: Text("")),
                showStat(model.count4, Icons.done, Colors.green),
                const Expanded(child: Text("")),
                showStat(model.count5, Icons.done_all, Colors.lightGreen),
              ],
            ),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _content(model),
            )),
            model.isComplete
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(child: Text("")),
                      textLink('פ', 'https://www.pealim.com/search/?q=${model.he0}'),
                      const Expanded(child: Text("")),
                      textLink('מ', 'https://www.morfix.co.il/${model.he0}'),
                      const Expanded(child: Text("")),
                      textLink('r',
                          'https://context.reverso.net/translation/hebrew-english/${model.he0}'),
                      const Expanded(child: Text(""))
                    ],
                  )
                : const Text("")
          ],
        ));
  }

  TextButton textLink(String name, String link) {
    return TextButton(
        onPressed: () {
          launchUrlString(link);
        },
        child: Text(name,
            textScaleFactor: 3.5,
            style: const TextStyle(color: Colors.black26, fontWeight: FontWeight.bold)));
  }

  Widget showStat(int number, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20),
        Text(' $number', textScaleFactor: 1.5, style: TextStyle(color: color))
      ],
    );
  }

  List<Widget> _content(VocabModel model) {
    return <Widget>[
      (model.guessMode == GuessMode.eng
          ? Text(
              model.eng0,
              textScaleFactor: 2,
              style: const TextStyle(fontWeight: FontWeight.w300),
            )
          : Text(
              model.he0,
              textScaleFactor: 2,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
              overflow: TextOverflow.clip,
            )),
      const Text("_______________________________________"),
      (model.guessMode == GuessMode.eng
          ? Text(model.he0,
              textScaleFactor: 2,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl)
          : Text(
              model.eng0,
              textScaleFactor: 2,
              overflow: TextOverflow.clip,
              style: const TextStyle(fontWeight: FontWeight.w300),
            )),
      const Text(""),
      const Text(""),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: model.hasEng1
            ? [
                Text(model.he1, textScaleFactor: 1.75, textDirection: TextDirection.rtl),
                const Text("   "),
                Text(
                  model.eng1,
                  textScaleFactor: 1.75,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(fontWeight: FontWeight.w300),
                )
              ]
            : [
                Text(
                  model.he1,
                  textScaleFactor: 1.75,
                  textDirection: TextDirection.rtl,
                  overflow: TextOverflow.clip,
                ),
              ],
      ),
      const Text(""),
      Text(
        model.he2,
        textScaleFactor: 1.75,
        textDirection: TextDirection.rtl,
        overflow: TextOverflow.clip,
      ),
      Text(
        model.eng2,
        textScaleFactor: 1.75,
        overflow: TextOverflow.clip,
        style: const TextStyle(fontWeight: FontWeight.w300),
      ),
    ];
  }

  Widget _buttons(WidgetRef ref) {
    var model = ref.watch(vocabProvider);
    var val = AppConfig.blockWidth / 3;
    var textScaleFactor = max(min(2.0, val), 1.0);

    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: !model.isComplete
          ? <Widget>[
              FloatingActionButton.extended(
                heroTag: 1,
                onPressed: () => model.showComplete(),
                label: const Text(
                  "           Show           ",
                  textScaleFactor: 1.75,
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              )
            ]
          : <Widget>[
              /*FloatingActionButton(
                backgroundColor: Colors.white,
                heroTag: 2,
                onPressed: () => model.nextItem(DataModelSettings.omitLevel),
                child: const Text("Hide", style: TextStyle(color: Colors.grey)),
              ),*/
              FloatingActionButton.extended(
                backgroundColor: Colors.red,
                heroTag: 3,
                onPressed: () => model.nextItem(1),
                label: Text(
                  "Again",
                  textScaleFactor: textScaleFactor,
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ),
              FloatingActionButton.extended(
                backgroundColor: Colors.orange,
                heroTag: 4,
                onPressed: () => model.nextItem(2),
                label: Text(
                  "Hard",
                  textScaleFactor: textScaleFactor,
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ),
              FloatingActionButton.extended(
                backgroundColor: Colors.lightBlueAccent,
                heroTag: 5,
                onPressed: () => model.nextItem(3),
                label: Text(
                  "Good",
                  textScaleFactor: textScaleFactor,
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ),
              FloatingActionButton.extended(
                backgroundColor: Colors.green,
                heroTag: 6,
                onPressed: () => model.nextItem(4),
                label: Text(
                  "Easy",
                  textScaleFactor: textScaleFactor,
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ),
            ],
    );
  }
}
