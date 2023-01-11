import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mila/Page.Vocabulary/VocabProviders.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../Data/DataModelSettings.dart';
import '../Data/Item.dart';
import '../Library/Library.dart';
import '../Library/Result.dart';
import '../Data/SourceError.dart';
import 'VocabDialogs.dart';
import 'VocabModel.dart';
import '../main.dart';

typedef ModelOrError = Result<VocabModel, SourceError>;

const lightFont = TextStyle(fontWeight: FontWeight.w300);
const italicFont = TextStyle(fontWeight: FontWeight.w300, fontStyle: FontStyle.italic);
const boldFont = TextStyle(fontWeight: FontWeight.bold);
const linkFont = TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.w300);

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
    //---------------------- ERROR VIEW ----------------------
    if (!result.hasValue) {
      var error = result.error!;
      return Scaffold(
        appBar: AppBar(title: Text('${error.name} 〈${error.length}〉')),
        body: Center(
            child: SingleChildScrollView(
                child: Text(error.description,
                    textScaleFactor: 1.75, style: lightFont, textAlign: TextAlign.center))),
        bottomNavigationBar: Text(error.message,
            textScaleFactor: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
      );
    }

    var model = ref.watch(vocabProvider);
    model.initialize();

    //----------------------  NOTHING TO LEARN VIEW ----------------------
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

    //----------------------  MAIN VIEW ----------------------
    return Scaffold(
        appBar: AppBar(title: Text('${model.sourceName} 〈${model.length}〉'), actions: <Widget>[
          _menu(context, model)]),
        body: _body(context, model),
        bottomNavigationBar: _buttons(model));
  }

  PopupMenuButton<int> _menu(BuildContext context, VocabModel model) {
    return PopupMenuButton<int>(
      onSelected: (v) => _menuSelection(v, context, model),
      child:
          const Padding(padding: EdgeInsets.only(right: 20.0), child: Icon(Icons.menu, size: 26)),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<int>(value: 0, enabled: model.isComplete, child: const Text('Skip item')),
        PopupMenuItem<int>(value: 1, enabled: model.isComplete, child: const Text('Hide item')),
        PopupMenuItem<int>(
            value: 2, enabled: model.hasPrevious, child: const Text('Previous item')),
        const PopupMenuDivider(),
        const PopupMenuItem<int>(value: 3, child: Text('Reset all items')),
        PopupMenuItem<int>(
            value: 4, enabled: model.isComplete, child: const Text('Reset this item')),
        const PopupMenuItem<int>(value: 5, child: Text('Reset hidden items')),
      ],
    );
  }

  Widget _body(BuildContext context, VocabModel model) {
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
                Text(
                  (model.pendingNo == null || model.pendingNo == 0)
                      ? ''
                      : model.pendingNo.toString(),
                  textScaleFactor: 4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black12),
                )
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
                      textLink(
                          'פ', 'https://www.pealim.com/search/?q=${model.currentItem!.target}'),
                      const Expanded(child: Text("")),
                      textLink('m', 'https://www.morfix.co.il/${model.currentItem!.target}'),
                      const Expanded(child: Text("")),
                      textLink('מ', 'https://milog.co.il/${model.currentItem!.target}'),
                      const Expanded(child: Text("")),
                      textLink('g',
                          'https://translate.google.com/?sl=iw&tl=en&text=${model.currentItem!.target}'),
                      const Expanded(child: Text("")),
                      textLink('r',
                          'https://context.reverso.net/translation/hebrew-english/${model.currentItem!.target}'),
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
      onPressed: () => VocabDialogs.statDialog(context, items),
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
        model.phonetic,
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
              customButton(model, DataModelSettings.valueAgain, Colors.orange),
              customButton(model, DataModelSettings.valueGood, Colors.lightBlueAccent),
              customButton(model, DataModelSettings.valueEasy, Colors.green),
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
    if (value == 0) model.nextItem(DataModelSettings.tailLevel);
    if (value == 1) model.nextItem(DataModelSettings.hiddenLevel);
    if (value == 2) model.prevItem();
    if (value == 3) VocabDialogs.resetAllDialog(context, model);
    if (value == 4) model.nextItem(DataModelSettings.undoneLevel);
    if (value == 5) model.resetItems((item) => item.level == DataModelSettings.hiddenLevel);
  }
}
