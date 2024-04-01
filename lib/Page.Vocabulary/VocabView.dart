import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:mila/IO/ISerializer.dart';
import 'package:mila/Page.Vocabulary/VocabProviders.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../Data/DataModelSettings.dart';
import '../Data/Item.dart';
import '../Library/Result.dart';
import '../Data/SourceError.dart';
import '../Library/Widgets.dart';
import '../Page.Sources/SourceDialogs.dart';
import 'SIngleChildScrollableWithHints.dart';
import 'VocabDialogs.dart';
import 'VocabModel.dart';

typedef ModelOrError = Result<VocabModel, SourceError>;

const lightFont = TextStyle(fontWeight: FontWeight.w300);
const italicFont = TextStyle(fontWeight: FontWeight.w300, fontStyle: FontStyle.italic);
const boldFont = TextStyle(fontWeight: FontWeight.bold);
const linkFont = TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.w300);

class VocabView extends ConsumerWidget {
  const VocabView({Key? key}) : super(key: key);

  @override
  Widget build(context, ref) {
    final asyncModel = ref.watch(vocabModelProvider);
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
                    textScaler: const TextScaler.linear(1.75),
                    style: lightFont,
                    textAlign: TextAlign.center))),
        bottomNavigationBar: Text(error.message,
            textScaler: const TextScaler.linear(2),
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
            textScaler: TextScaler.linear(2),
            style: lightFont,
            textAlign: TextAlign.center,
          )));
    }

    //-------------------------  MAIN VIEW -------------------------

    return Scaffold(
        appBar: AppBar(
            title: Text('${model.sourceName} 〈${model.length}〉'),
            actions: <Widget>[_menu(context, model)]),
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
        const PopupMenuItem<int>(value: 3, child: Text('Export vocabulary')),
        const PopupMenuItem<int>(value: 4, child: Text('Reset all items')),
        PopupMenuItem<int>(
            value: 5, enabled: model.isComplete, child: const Text('Reset this item')),
        const PopupMenuItem<int>(value: 6, child: Text('Reset hidden items')),
        const PopupMenuItem<int>(value: 7, child: Text('Mark all items as learned')),
      ],
    );
  }

  Widget _body(BuildContext context, VocabModel model) {
    var stat = model.statistics();
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                statisticsRow(context, stat),
                Text(
                  model.message,
                  textScaler: const TextScaler.linear(4),
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
            model.isComplete ? linksRow(model) : const Text("")
          ],
        ));
  }

  Widget statisticsRow(BuildContext context, Statistics stat) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Widgets.statWidget(context, stat.hidden, Icons.do_disturb_on_outlined, Colors.black38),
        Widgets.statWidget(context, stat.undone, Icons.hourglass_empty_sharp, Colors.black45),
        Widgets.statWidget(context, stat.repeat, Icons.repeat, Colors.orange),
        Widgets.statWidget(context, stat.done, Icons.done, Colors.green),
        Widgets.statWidget(context, stat.doneAll, Icons.done_all, Colors.lightGreen),
      ],
    );
  }

  Widget linksRow(VocabModel model) {
    // var links = model.links;
    // var widgets = <TextButton>[];
    //
    // if (links.length == 1) {
    //   widgets.add(textLink("link", 2.25, links[0], fontWeight: FontWeight.normal));
    // } else {
    //   for (var i = 0; i < links.length; i++) {
    //     widgets.add(textLink("link ${i + 1}", 2.25, links[i], fontWeight: FontWeight.normal));
    //   }
    // }

    // return Column(children: [
    //   Row(
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     mainAxisAlignment: MainAxisAlignment.spaceAround,
    //     children: widgets,
    //   ),
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        textLink('פ', 2.5, 'https://www.pealim.com/search/?q=${model.currentItem!.target}'),
        textLink('m', 3.0, 'https://www.morfix.co.il/${model.currentItem!.target}'),
        textLink('מ', 2.5, 'https://milog.co.il/${model.currentItem!.target}'),
        textLink('T', 3.0,
            'https://tatoeba.org/en/sentences/search?from=heb&query=${model.currentItem!.target}&to=eng'),
        textLink('g', 3.0,
            'https://translate.google.com/?sl=iw&tl=en&text=${model.currentItem!.target}'),
        textLink('r', 3.0,
            'https://context.reverso.net/translation/hebrew-english/${model.currentItem!.target}')
      ],
    );
    //]);
  }

  TextButton textLink(String name, double factor, String link,
      {Color color = Colors.black12, FontWeight fontWeight = FontWeight.bold}) {
    return TextButton(
        onPressed: () => launchUrlString(link),
        child: Text(name,
            textDirection: TextDirection.rtl,
            overflow: TextOverflow.clip,
            textScaler: TextScaler.linear(factor), // bigger fonts for latin
            style: TextStyle(color: color, fontWeight: fontWeight)));
  }

  List<Widget> _content(VocabModel model) {
    var heScale = model.he0.length < 12 ? 2.25 : 2.0;

    return <Widget>[
      (model.guessMode == GuessMode.eng
          ? Text(
              model.eng0,
              textScaler: const TextScaler.linear(2),
              style: lightFont,
            )
          : Text(
              model.he0,
              textScaler: TextScaler.linear(heScale),
              style: boldFont,
              textDirection: TextDirection.rtl,
              overflow: TextOverflow.ellipsis,
            )),
      const Text("_______________________________________",
          style: TextStyle(color: Colors.black26)),
      (model.guessMode == GuessMode.eng
          ? Text(model.he0,
              textScaler: TextScaler.linear(heScale),
              style: boldFont,
              textDirection: TextDirection.rtl)
          : Text(
              model.eng0,
              textScaler: const TextScaler.linear(2),
              overflow: TextOverflow.ellipsis,
              style: lightFont,
            )),
      Text(
        model.phonetic,
        textScaler: const TextScaler.linear(1.75),
        overflow: TextOverflow.ellipsis,
        style: italicFont,
      ),
      const Text(""),
      Flexible(
        child: SingleChildScrollableWithHints(
          child: relatedWidget(model),
        ),
      ),
    ];
  }

  List<Set<Item>> getRelated(VocabModel model) {
    var inf = <Item>{};
    var syn = <Item>{};
    var root = <Item>{};
    var phr = <Item>{};
    var decl = <Item>{};

    for (var kvp in model.related.entries) {
      var item = kvp.key;
      if (item.haser.contains(' '))
        phr.add(item);
      else if (isVerb(item))
        inf.add(item);
      else if (kvp.value && isDecl(item))
        decl.add(item);
      else if (kvp.value)
        root.add(item);
      else
        syn.add(item);
    }

    var secondary = [inf, decl, syn, root, phr];
    return secondary;
  }

  bool isVerb(Item item) => item.haser.startsWith('ל') && item.translation.startsWith('to ');

  bool isDecl(Item item) =>
      item.translation.startsWith('I ') ||
      item.translation.startsWith('you ') ||
      item.translation.startsWith('he ') ||
      item.translation.startsWith('she ') ||
      item.translation.startsWith('we ') ||
      item.translation.startsWith('they ');

  Widget relatedWidget(VocabModel model) {
    var list = getRelated(model);

    var he = <String>[];
    var eng = <String>[];

    for (var set in list) {
      if (set.isEmpty) continue;

      var ordered = set.orderBy((item) => item.haser).toList();
      var he1 = ordered.select((item, _) => item.target).join("\n");
      var eng1 = ordered.select((item, _) => item.translation).join("\n");

      he.add(he1);
      eng.add(eng1);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(he.join("\n\n"),
            textScaler: const TextScaler.linear(1.75), textDirection: TextDirection.rtl),
        const Text("   "),
        Text(
          eng.join("\n\n"),
          textScaler: const TextScaler.linear(1.75),
          overflow: TextOverflow.ellipsis,
          style: lightFont,
        )
      ],
    );

    // if (model.he2.isNotEmpty) ...[
    //   const Text(""),
    //   textLink(model.he2, 1.75, 'https://translate.google.com/?sl=iw&tl=en&text=${model.he2}',
    //       color: Colors.black, fontWeight: FontWeight.normal),
    //   Text(
    //     model.eng2,
    //     textScaler: const TextScaler.linear(1.75),
    //     overflow: TextOverflow.clip,
    //     style: lightFont,
    //   ),
    // ]
  }

  Widget _buttons(VocabModel model) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: !model.isComplete
          ? <Widget>[
              FloatingActionButton.extended(
                heroTag: 1,
                backgroundColor: Colors.cyan,
                onPressed: () => model.showComplete(),
                label: const Text(
                  "           Show           ",
                  textScaler: TextScaler.linear(1.75),
                  style: lightFont,
                ),
              )
            ]
          : <Widget>[
              customButton(model, Skill.again, 4),
              customButton(model, Skill.good, 5),
              customButton(model, Skill.easy, 6),
            ],
    );
  }

  FloatingActionButton customButton(VocabModel model, Skill skill, int heroTag) {
    return FloatingActionButton.extended(
      backgroundColor: skill.color,
      heroTag: heroTag,
      onPressed: () => model.nextItemForSkill(skill),
      label: Text(
        skill.text,
        textScaler: const TextScaler.linear(1.75),
        style: lightFont,
      ),
    );
  }

  void _menuSelection(int value, BuildContext context, VocabModel model) {

    var s = GetIt.I<ISerializer>();

    if (value == 0) model.nextItemForLevel(DataModelSettings.skipLevel);
    if (value == 1) model.nextItemForLevel(DataModelSettings.hideLevel);
    if (value == 2) model.prevItem();

    if (value == 3) SourceDialogs.showExported(context, s.export());
    if (value == 4) VocabDialogs.resetAllDialog(context, model);
    if (value == 5) model.nextItemForLevel(DataModelSettings.undoneLevel);
    if (value == 6) {
      model.resetItems(
          (item) => item.level == DataModelSettings.hideLevel, DataModelSettings.undoneLevel);
    }
    if (value == 7) model.resetItems((item) => true, DataModelSettings.yearIndex + 1);
  }
}
