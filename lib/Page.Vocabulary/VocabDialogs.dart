import 'package:darq/darq.dart';
import 'package:flutter/material.dart';

import '../Data/Item.dart';
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
}
