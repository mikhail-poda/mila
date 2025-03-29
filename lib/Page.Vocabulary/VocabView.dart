import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
const italicFont =
    TextStyle(fontWeight: FontWeight.w300, fontStyle: FontStyle.italic);
const boldFont = TextStyle(fontWeight: FontWeight.bold);
const linkFont =
    TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.w300);
const grayFont = TextStyle(color: Colors.black38, fontWeight: FontWeight.w300);

var conjugationComparer = EqualityComparer<String>(sorter: conjugationSorter);

class VocabView extends ConsumerWidget {
  const VocabView({super.key});

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
            data: (asyncData) =>
                _buildScaffold(context, ref, asyncData.value)));
  }

  Scaffold _buildScaffold(BuildContext context, WidgetRef ref,
      Result<VocabModel, SourceError> result) {
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
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.red)),
      );
    }

    var model = ref.watch(vocabProvider);
    model.initialize();

    //----------------------  NOTHING TO LEARN VIEW ----------------------
    if (!model.hasItem) {
      return Scaffold(
          appBar: AppBar(
              title: Text('${model.sourceName} • ${model.length}'),
              actions: <Widget>[
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
            title: Text('${model.sourceName} • ${model.length}'),
            actions: <Widget>[_menu(context, model)]),
        body: _body(context, model),
        bottomNavigationBar: _buttons(model));
  }

  PopupMenuButton<int> _menu(BuildContext context, VocabModel model) {
    return PopupMenuButton<int>(
      onSelected: (v) => _menuSelection(v, context, model),
      child: const Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: Icon(Icons.menu, size: 26)),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<int>(
            value: 0,
            enabled: model.isComplete,
            child: const Text('Skip item')),
        PopupMenuItem<int>(
            value: 1,
            enabled: model.isComplete,
            child: const Text('Hide item')),
        PopupMenuItem<int>(
            value: 2,
            enabled: model.hasPrevious,
            child: const Text('Previous item')),
        const PopupMenuDivider(),
        const PopupMenuItem<int>(value: 3, child: Text('Export vocabulary')),
        const PopupMenuItem<int>(value: 4, child: Text('Reset all items')),
        PopupMenuItem<int>(
            value: 5,
            enabled: model.isComplete,
            child: const Text('Reset this item')),
        const PopupMenuItem<int>(value: 6, child: Text('Reset hidden items')),
        const PopupMenuItem<int>(
            value: 7, child: Text('Mark all items as learned')),
      ],
    );
  }

  Widget _body(BuildContext context, VocabModel model) {
    var stat = model.statistics();
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            statisticsRow(context, stat),
            Expanded(child: _content(model)),
            model.isComplete ? linksRow(model) : const Text("")
          ],
        ));
  }

  Widget statisticsRow(BuildContext context, Statistics stat) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Widgets.statWidget(
            context, stat.hidden, Icons.do_disturb_on_outlined, Colors.black38),
        Widgets.statWidget(
            context, stat.undone, Icons.hourglass_empty_sharp, Colors.black45),
        Widgets.statWidget(context, stat.repeat, Icons.repeat, Colors.orange),
        Widgets.statWidget(context, stat.done, Icons.done, Colors.green),
        Widgets.statWidget(
            context, stat.doneAll, Icons.done_all, Colors.lightGreen),
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
        textLink('פ', 2.5,
            'https://www.pealim.com/search/?q=${model.currentItem!.target}'),
        textLink(
            'm', 3.0, 'https://www.morfix.co.il/${model.currentItem!.target}'),
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

  Widget _content(VocabModel model) {
    var heScale = model.he0.length < 12 ? 2.25 : 2.0;

    return SingleChildScrollableWithHints(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          Text(
            model.message,
            textScaler: const TextScaler.linear(4),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black12),
          ),
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
          ...relatedWidgets(model),
        ]));
  }

  List<Set<Item>> getRelated(VocabModel model) {
    var verb = <Item>{};
    var syn = <Item>{};
    var root = <Item>{};
    var phr = <Item>{};
    var conj = <Item>{};

    for (var kvp in model.related.entries) {
      var item = kvp.key;
      var isSameRoot = kvp.value;

      if (item.haser.contains(' ')) {
        phr.add(item);
      } else if (isVerb(item))
        verb.add(item);
      else if (isSameRoot && isConjugation(item.translation))
        conj.add(item);
      else if (isSameRoot)
        root.add(item);
      else
        syn.add(item);
    }

    var secondary = [syn, verb, conj, root, phr];
    return secondary;
  }

  bool isConjugation(String str) => getConjugationOrder(str) > 0;

  bool isVerb(Item item) =>
      item.haser.startsWith('ל') && item.translation.startsWith('to ');

  List<Widget> relatedWidgets(VocabModel model) {
    var list = getRelated(model);
    var headers = ['synonyms', 'verbs', 'conjugation', 'same root', 'phrase'];

    return list
        .zip(headers, (l, h) => makeWidget(l, h))
        .where((element) => element != null)
        .cast<Widget>()
        .toList();
  }

  Widget? makeWidget(Set<Item> set, String header) {
    if (set.isEmpty) return null;
    var (he, eng) = _heEng(header, set);
    return _heEngRow(header, he, eng);
  }

  Widget _heEngRow(String header, String he2, String eng2) {
    var row0 = const Text('');
    var row1 = Text(
      '      $header  -------------------------',
      style: grayFont,
      textScaler: const TextScaler.linear(1.50),
    );
    var row2 = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(he2,
            textScaler: const TextScaler.linear(1.75),
            textDirection: TextDirection.rtl),
        const Text("   "),
        Text(
          eng2,
          textScaler: const TextScaler.linear(1.75),
          overflow: TextOverflow.ellipsis,
          style: lightFont,
        )
      ],
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [row0, row1, row2],
    );
  }

  (String, String) _heEng(String header, Set<Item> set) {
    var ordered = header == 'conjugation'
        ? set
            .orderBy<String>((item) => item.translation,
                keyComparer: conjugationComparer)
            .toList()
        : set.orderBy((item) => item.haser).toList();

    var he = ordered.select((item, _) => item.target).join("\n");
    var eng = ordered.select((item, _) => item.translation).join("\n");
    return (he, eng);
  }

  Widget _buttons(VocabModel model) {
    return OverflowBar(
      alignment: MainAxisAlignment.center,
      children: !model.isComplete
          ? <Widget>[
              customButton(Colors.cyan, 1, "           Show           ",
                  () => model.showComplete())
            ]
          : <Widget>[
              skillButton(model, Skill.again, 4),
              skillButton(model, Skill.good, 5),
              skillButton(model, Skill.easy, 6),
            ],
    );
  }

  Widget skillButton(VocabModel model, Skill skill, int heroTag) {
    return customButton(
        skill.color, heroTag, skill.text, () => model.nextItemForSkill(skill));
  }

  Widget customButton(
      Color? backgroundColor, int heroTag, String label, Function onPressed) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton.extended(
          backgroundColor: backgroundColor,
          heroTag: heroTag,
          onPressed: () => onPressed(),
          label: Text(
            label,
            textScaler: const TextScaler.linear(1.75),
            style: lightFont,
          ),
        ));
  }

  void _menuSelection(int value, BuildContext context, VocabModel model) {
    if (value == 0) model.nextItemForLevel(DataModelSettings.skipLevel);
    if (value == 1) model.nextItemForLevel(DataModelSettings.hideLevel);
    if (value == 2) model.prevItem();

    if (value == 3) SourceDialogs.showExported(context, model.export());
    if (value == 4) {
      VocabDialogs.resetAllDialog(context,
          () => model.resetItems((i) => true, DataModelSettings.undoneLevel));
    }
    if (value == 5) model.nextItemForLevel(DataModelSettings.undoneLevel);
    if (value == 6) {
      model.resetItems((item) => item.level == DataModelSettings.hideLevel,
          DataModelSettings.undoneLevel);
    }
    if (value == 7) {
      model.resetItems((item) => true, DataModelSettings.yearIndex + 1);
    }
  }
}

int conjugationSorter(String left, String right) =>
    getConjugationOrder(left) - getConjugationOrder(right);

int getConjugationOrder(String str) => str.startsWith('I ')
    ? 1
    : str.startsWith('you ')
        ? 2
        : str.startsWith('he ')
            ? 3
            : str.startsWith('she ')
                ? 4
                : str.startsWith('it ')
                    ? 5
                    : str.startsWith('we ')
                        ? 6
                        : str.startsWith('they ')
                            ? 7
                            : 0;
