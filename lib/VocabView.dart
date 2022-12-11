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
import 'Result.dart';
import 'SourcesView.dart';
import 'VocabModel.dart';
import 'main.dart';

typedef ModelOrError = Result<VocabModel, SourceError>;

const lightFont = TextStyle(fontWeight: FontWeight.w300);
const italicFont = TextStyle(fontWeight: FontWeight.w300, fontStyle: FontStyle.italic);
const boldFont = TextStyle(fontWeight: FontWeight.bold);
const linkFont = TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.w300);

final fileResultProvider = FutureProvider<ModelOrError>((ref) async {
  final sourceName = ref.watch(vocabularyNameProvider);

  var isSerializer = sourceName == serialName;
  var lines = isSerializer
      ? GetIt.I<ISerializer>().loadVocabulary()
      : GetIt.I<ISource>().loadVocabulary(sourceName);

  final items = await lines.map((e) => Item(e)).toList();
  final err = SourceError.any(sourceName, items);
  if (err != null) return ModelOrError.error(err);

  Item.addSecondary(items);
  Item.addSynonyms(items);

  final serializer = GetIt.I<ISerializer>();
  final model = VocabModel(sourceName, items, serializer);
  return ModelOrError.value(model);
});

final vocabProvider = ChangeNotifierProvider<VocabModel>((ref) {
  var model = ref.watch(fileResultProvider).value;
  return model!.value!;
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
            data: (asyncData) => _buildScaffold(context, ref, asyncData.value)));
  }

  Scaffold _buildScaffold(
      BuildContext context, WidgetRef ref, Result<VocabModel, SourceError> result) {
    if (!result.hasValue) {
      var error = result.error!;
      return Scaffold(
        appBar: AppBar(title: Text('${error.name} 〈${error.length}〉')),
        body: Center(
            child: Text(
          error.description,
          textScaleFactor: 2,
          style: lightFont,
          textAlign: TextAlign.center,
        )),
        bottomNavigationBar: Text(error.message,
            textScaleFactor: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
      );
    }

    var model = ref.watch(vocabProvider);
    model.initialize();

    if (!model.hasItem) {
      return Scaffold(
          appBar: AppBar(title: Text('${model.sourceName} 〈${model.length}〉'), actions: <Widget>[
            _menu(context, model),
          ]),
          body: const Center(
              child: Text(
            "Nothing to learn for today!",
            textScaleFactor: 2,
            style: lightFont,
            textAlign: TextAlign.center,
          )));
    }

    return Scaffold(
        appBar: AppBar(title: Text('${model.sourceName} 〈${model.length}〉'), actions: <Widget>[
          _menu(context, model),
        ]),
        body: _body(context, model),
        bottomNavigationBar: _buttons(model));
  }

  PopupMenuButton<int> _menu(BuildContext context, VocabModel model) {
    return PopupMenuButton<int>(
      onSelected: (v) => _menuSelection(v, context, model),
      child:
          const Padding(padding: EdgeInsets.only(right: 20.0), child: Icon(Icons.menu, size: 26)),
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
        PopupMenuItem<int>(value: 5, enabled: model.isComplete, child: const Text('Hide item')),
        PopupMenuItem<int>(
            value: 6, enabled: model.hasPrevious, child: const Text('Previous item')),
        const PopupMenuItem<int>(value: 7, child: Text('Reset all items')),
        PopupMenuItem<int>(
            value: 8, enabled: model.isComplete, child: const Text('Reset this item')),
        const PopupMenuItem<int>(value: 9, child: Text('Reset hidden items')),
      ],
    );
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
                      const Text("Iteration Order:", textScaleFactor: 1.75, style: lightFont),
                      ToggleSwitch(
                        totalSwitches: 2,
                        labels: const ['Sequential', 'Random'],
                        onToggle: (index) => model.setIterationMode(index!),
                        initialLabelIndex: model.iterationMode.index,
                      ),
                      const Text(""),
                      const Text("Display Order:", textScaleFactor: 1.75, style: lightFont),
                      ToggleSwitch(
                        totalSwitches: 4,
                        labels: const ['He', 'Eng', 'Random', 'Both'],
                        onToggle: (index) => model.setDisplayMode(index!),
                        initialLabelIndex: model.displayMode.index,
                      ),
                      const Text(""),
                      const Text("Show Nikud:", textScaleFactor: 1.75, style: lightFont),
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
                      const Text("Mikhail Poda\r\nOctober 2022\r\nBraunschweig, Germany\r\n",
                          textScaleFactor: 1.75, style: lightFont),
                      TextButton(
                          onPressed: () => launchUrlString(uri),
                          child: const Text(
                            "vocabulary source",
                            textScaleFactor: 1.75,
                            style: linkFont,
                          )),
                      TextButton(
                          onPressed: () => launchUrlString("mailto:mikhail.poda@gmail.com"),
                          child: const Text(
                            "mikhail.poda@gmail.com",
                            textScaleFactor: 1.75,
                            style: linkFont,
                          )),
                      TextButton(
                          onPressed: () => launchUrlString("https://github.com/mikhail-poda/mila"),
                          child: const Text(
                            "https://github.com/mikhail-poda/mila",
                            textScaleFactor: 1.75,
                            style: linkFont,
                          )),
                    ],
                  )));
        });
  }

  Widget _body(BuildContext context, VocabModel model) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                statWidget(context, model.count1, Icons.do_disturb_on_outlined, Colors.black38),
                const Expanded(child: Text("")),
                statWidget(context, model.count2, Icons.hourglass_empty_sharp, Colors.black45),
                const Expanded(child: Text("")),
                statWidget(context, model.count3, Icons.repeat, Colors.orange),
                const Expanded(child: Text("")),
                statWidget(context, model.count4, Icons.done, Colors.green),
                const Expanded(child: Text("")),
                statWidget(context, model.count5, Icons.done_all, Colors.lightGreen),
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
                      textLink('פ', 'https://www.pealim.com/search/?q=${haserNikud(model.he0)}'),
                      const Expanded(child: Text("")),
                      textLink('m', 'https://www.morfix.co.il/${haserNikud(model.he0)}'),
                      const Expanded(child: Text("")),
                      textLink('מ', 'https://milog.co.il/${haserNikud(model.he0)}'),
                      const Expanded(child: Text("")),
                      textLink('g',
                          'https://translate.google.com/?sl=iw&tl=en&text=${haserNikud(model.he0)}'),
                      const Expanded(child: Text("")),
                      textLink('r',
                          'https://context.reverso.net/translation/hebrew-english/${haserNikud(model.he0)}'),
                      const Expanded(child: Text(""))
                    ],
                  )
                : const Text("")
          ],
        ));
  }

  TextButton textLink(String name, String link) {
    return TextButton(
        onPressed: () => launchUrlString(link),
        child: Text(name,
            textScaleFactor: hasHebrew(name) ? 2.5 : 3.0, // bigger fonts for latin
            style: const TextStyle(color: Colors.black12, fontWeight: FontWeight.bold)));
  }

  Widget statWidget(BuildContext context, List<Item> items, IconData icon, Color color) {
    return TextButton(
      onPressed: () => statDisplay(context, items),
      child: Row(children: <Widget>[
        Icon(icon, size: 20, color: Colors.black54),
        Text(' ${items.length}', textScaleFactor: 1.5, style: TextStyle(color: color))
      ]),
    );
  }

  List<Widget> _content(VocabModel model) {
    return <Widget>[
      (model.guessMode == GuessMode.eng
          ? Text(
              model.eng0,
              textScaleFactor: 2,
              style: lightFont,
            )
          : Text(
              model.he0,
              textScaleFactor: 2,
              style: boldFont,
              textDirection: TextDirection.rtl,
              overflow: TextOverflow.clip,
            )),
      const Text("_______________________________________"),
      (model.guessMode == GuessMode.eng
          ? Text(model.he0, textScaleFactor: 2, style: boldFont, textDirection: TextDirection.rtl)
          : Text(
              model.eng0,
              textScaleFactor: 2,
              overflow: TextOverflow.clip,
              style: lightFont,
            )),
      Text(
        model.heng0,
        textScaleFactor: 1.75,
        overflow: TextOverflow.clip,
        style: italicFont,
      ),
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
                  style: lightFont,
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
        style: lightFont,
      ),
    ];
  }

  Widget _buttons(VocabModel model) {
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
                  style: lightFont,
                ),
              )
            ]
          : <Widget>[
              customButton(model, DataModelSettings.value1, Colors.orange),
              customButton(model, DataModelSettings.value2, Colors.lightBlueAccent),
              customButton(model, DataModelSettings.value3, Colors.green),
            ],
    );
  }

  FloatingActionButton customButton(VocabModel model, int ind, Color color) {
    return FloatingActionButton.extended(
      backgroundColor: color,
      heroTag: ind + 2,
      onPressed: () => model.nextItem(ind),
      label: Text(
        DataModelSettings.levels[ind - 1],
        textScaleFactor: 1.75,
        style: lightFont,
      ),
    );
  }

  void _menuSelection(int value, BuildContext context, VocabModel model) {
    if (value == 2) _settings(context, model);
    if (value == 3) _about(context);
    if (value == 4) model.nextItem(DataModelSettings.tailLevel);
    if (value == 5) model.nextItem(DataModelSettings.hiddenLevel);
    if (value == 6) model.prevItem();
    if (value == 7) _resetAll(context, model);
    if (value == 8) model.nextItem(DataModelSettings.undoneLevel);
    if (value == 9) model.resetItems((item) => item.level == DataModelSettings.hiddenLevel);
  }

  void _resetAll(BuildContext context, VocabModel model) async {
    bool result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation', textScaleFactor: 1.5),
          content: const Text('Do you want to reset all items?', textScaleFactor: 1.5),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pop(false); // dismisses only the dialog and returns false
              },
              child: const Text('No', textScaleFactor: 1.5),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pop(true); // dismisses only the dialog and returns true
              },
              child: const Text('Yes', textScaleFactor: 1.5),
            ),
          ],
        );
      },
    );

    if (result) model.resetItems((i) => true);
  }

  statDisplay(BuildContext context, List<Item> items) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                      child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items.select((i, j) => i.he0).join('\n'),
                        textDirection: TextDirection.rtl,
                        overflow: TextOverflow.clip,
                        textScaleFactor: 1.25,
                      ),
                      Text(
                        items.select((i, j) => '  ${i.eng0}').join('\n'),
                        overflow: TextOverflow.clip,
                        textScaleFactor: 1.25,
                      )
                    ],
                  ))));
        });
  }
}
