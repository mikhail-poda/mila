import 'package:darq/darq.dart';
import 'package:flutter/material.dart';

import '../Data/Item.dart';

class Widgets {
  static Widget statWidget(BuildContext context, List<IItem> items, IconData icon, Color color) {
    return TextButton(
      onPressed: () => statDialog(context, items),
      child: Row(children: <Widget>[
        Icon(icon, size: 20, color: Colors.black54),
        Text(' ${items.length}', textScaleFactor: 1.5, style: TextStyle(color: color))
      ]),
    );
  }

  static statDialog(BuildContext context, List<IItem> items) {
    var sorted = items.take(100).orderBy((item) => item.target).toList();

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
}
