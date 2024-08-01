import 'package:flutter/material.dart';


const lightFont = TextStyle(fontWeight: FontWeight.w300);
const linkFont = TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.w300);

class VocabDialogs {
  static resetAllDialog(BuildContext context, void Function() func) async {
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

    if (result) func();
  }
}
