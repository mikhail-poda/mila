import 'dart:math';

import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:mila/ISerializer.dart';
import 'package:mila/Item.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'Constants.dart';
import 'DataModel.dart';
import 'Library.dart';
import 'SourcesView.dart';
import 'VocabModel.dart';
import 'main.dart';

final fileResultProvider = FutureProvider<VocabModel>((ref) async {
  final source = ref.watch(vocabularyNameProvider);

  var lines = source == serialName
      ? GetIt.I<ISerializer>().loadVocabulary()
      : GetIt.I<ISource>().loadVocabulary(source);

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
    var num = model.repetitions.distinct((e) => haserNikud(e.he0)).length;

    if (num == 0) {
      return Scaffold(
          appBar: AppBar(title: Text('${model.sourceName} 〈${model.length}〉'), actions: <Widget>[
            PopupMenuButton<int>(
              onSelected: (v) => _menuSelection(v, context, model),
              child: const Padding(
                  padding: EdgeInsets.only(right: 20.0), child: Icon(Icons.menu, size: 26)),
              itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
                const PopupMenuItem<int>(
                  value: 1,
                  enabled: false,
                  child: Text('Download vocabulary'),
                ),
                const PopupMenuItem<int>(value: 2, child: Text('Settings')),
                const PopupMenuItem<int>(value: 3, child: Text('About')),
                PopupMenuItem<int>(
                    value: 4,
                    enabled: model.isComplete,
                    child: const Text('Move item to the end of the list')),
                PopupMenuItem<int>(
                    value: 5, enabled: model.isComplete, child: const Text('Hide item')),
              ],
            ),
          ]),
          body: _body(model),
          bottomNavigationBar: _buttons(model));
    } else {
      return Scaffold(
          appBar: AppBar(title: Text('${model.sourceName} 〈${model.length}〉')),
          body: _repetitionsView(model.repetitions),
          bottomNavigationBar: Text(
            'Error: $num repetitions found.',
            textScaleFactor: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ));
    }
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
                          textScaleFactor: 1.75, style: TextStyle(fontWeight: FontWeight.w300)),
                      ToggleSwitch(
                        totalSwitches: 2,
                        labels: const ['Sequential', 'Random'],
                        onToggle: (index) => model.setIterationMode(index!),
                        initialLabelIndex: model.iterationMode.index,
                      ),
                      const Text(""),
                      const Text("Display Order:",
                          textScaleFactor: 1.75, style: TextStyle(fontWeight: FontWeight.w300)),
                      ToggleSwitch(
                        totalSwitches: 4,
                        labels: const ['He', 'Eng', 'Random', 'Both'],
                        onToggle: (index) => model.setDisplayMode(index!),
                        initialLabelIndex: model.displayMode.index,
                      ),
                      const Text(""),
                      const Text("Show Nikud:",
                          textScaleFactor: 1.75, style: TextStyle(fontWeight: FontWeight.w300)),
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

  void _about(BuildContext context) {
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
                      const Text(
                          "Mikhail Poda\r\nOctober 2022\r\nBraunschweig, Germany\r\n",
                          textScaleFactor: 1.75,
                          style: TextStyle(fontWeight: FontWeight.w300)),
                      TextButton(
                          onPressed: () {
                            launchUrlString("mailto:mikhail.poda@gmail.com");
                          },
                          child: const Text(
                            "mikhail.poda@gmail.com",
                            textScaleFactor: 1.75,
                            style:
                                TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.w300),
                          ))
                    ],
                  )));
        });
  }

  Widget _body(VocabModel model) {
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
            textScaleFactor: hasHebrew(name) ? 3.5 : 4, // bigger fonts for latin
            style: const TextStyle(color: Colors.black12, fontWeight: FontWeight.bold)));
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

  Widget _buttons(VocabModel model) {
    var val = AppConfig.blockWidth / 3;
    var textScaleFactor = max(min(2.0, val), 1.0);
    const textStyle = TextStyle(fontWeight: FontWeight.w300);

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
                  style: textStyle,
                ),
              )
            ]
          : <Widget>[
              customButton(model, textScaleFactor, textStyle, 0, Colors.red),
              customButton(model, textScaleFactor, textStyle, 1, Colors.orange),
              customButton(model, textScaleFactor, textStyle, 2, Colors.lightBlueAccent),
              customButton(model, textScaleFactor, textStyle, 3, Colors.green),
            ],
    );
  }

  FloatingActionButton customButton(
      VocabModel model, double textScaleFactor, TextStyle textStyle, int ind, Color color) {
    return FloatingActionButton.extended(
      backgroundColor: color,
      heroTag: ind + 2,
      onPressed: () => model.nextItem(ind + 1),
      label: Text(
        DataModelSettings.levels[ind],
        textScaleFactor: textScaleFactor,
        style: textStyle,
      ),
    );
  }

  Widget _repetitionsView(List<Item> repetitions) {
    return Center(
        child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: repetitions.length,
            itemBuilder: (BuildContext context, int index) {
              return Material(
                  child: ListTile(
                      title: Text(
                '${repetitions[index].he0} - ${repetitions[index].eng0}',
                textScaleFactor: 1.5,
                style: const TextStyle(fontWeight: FontWeight.w300),
              )));
            }));
  }

  void _menuSelection(int value, BuildContext context, VocabModel model) {
    if (value == 2) _settings(context, model);
    if (value == 3) _about(context);
    if (value == 4) model.nextItem(DataModelSettings.undoneLevel);
    if (value == 5) model.nextItem(DataModelSettings.hiddenLevel);
  }
}
