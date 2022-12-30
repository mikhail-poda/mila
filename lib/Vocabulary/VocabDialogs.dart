import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../Data/Item.dart';
import '../Constants.dart';
import 'VocabModel.dart';

const lightFont = TextStyle(fontWeight: FontWeight.w300);
const linkFont = TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.w300);

class VocabDialogs {
  static statDialog(BuildContext context, List<Item> items) {
    var sorted = items.take(100).orderBy((item) => item.id).toList();

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
                        sorted.select((i, j) => i.target).join('\n'),
                        textDirection: TextDirection.rtl,
                        overflow: TextOverflow.clip,
                        textScaleFactor: 1.25,
                      ),
                      Text(
                        sorted.select((i, j) => '  ${i.translation}').join('\n'),
                        overflow: TextOverflow.clip,
                        textScaleFactor: 1.25,
                      )
                    ],
                  ))));
        });
  }

  static settingsDialog(BuildContext context, VocabModel model) {
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

  static void aboutDialog(BuildContext context) {
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

  static resetAllDialog(BuildContext context, VocabModel model) async {
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

  static void exported(BuildContext context, int num) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text("Exported $num vocables"),
              ));
        });
  }

  static void imported(BuildContext context, Future<int> import) async {
    var num = await import;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("Imported $num vocables"),
          ));
        });
  }
}
