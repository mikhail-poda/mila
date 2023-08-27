import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../Constants.dart';
import '../IO/ISerializer.dart';
import '../IO/Settings.dart';

const lightFont = TextStyle(fontWeight: FontWeight.w300);
const linkFont = TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.w300);

class SourceDialogs {
  static settingsDialog(BuildContext context, ISerializer serializer) {
    var settings = serializer.getSettings();
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
                        onToggle: (index) {
                          settings.iterationMode = index!;
                          serializer.setSettings(settings);
                        },
                        initialLabelIndex: settings.iterationMode,
                      ),
                      const Text(""),
                      const Text("Display Order:", textScaleFactor: 1.75, style: lightFont),
                      ToggleSwitch(
                        totalSwitches: 4,
                        labels: const ['He', 'Eng', 'Random', 'Both'],
                        onToggle: (index) {
                          settings.displayMode = index!;
                          serializer.setSettings(settings);
                        },
                        initialLabelIndex: settings.displayMode,
                      ),
                      const Text(""),
                      const Text("Show Nikud:", textScaleFactor: 1.75, style: lightFont),
                      ToggleSwitch(
                        totalSwitches: 2,
                        labels: const ['א', '∵'],
                        onToggle: (index) {
                          settings.showNikud = index == 1;
                          serializer.setSettings(settings);
                        },
                        initialLabelIndex: settings.showNikud ? 1 : 0,
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

  static void showExported(BuildContext context, int num) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("Exported ${num} vocables"),
          ));
        });
  }

  static void showImported(BuildContext context, Future<int> import) async {
    var num = await import;
    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("Imported $num vocables"),
          )));
  }
}
