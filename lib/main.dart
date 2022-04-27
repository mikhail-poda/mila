import 'package:flutter/material.dart';
import 'package:mila/ViewModel.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'ViewModel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hebrew Vocabulary Trainer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Hebrew Vocabulary Trainer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ViewModel _model;

  _MyHomePageState() {
    _model =
        ViewModel(r'C:\Users\mikha\Downloads\daily.a.tsv', () => _nextGuess(0));
  }

  void _showComplete() {
    setState(() => _model.showComplete());
  }

  void _nextGuess(int level) {
    setState(() => _model.nextItem(level));
  }

  void _switchNikud(int? nikud) {
    setState(() => _model.showNikud = (nikud == 1));
  }

  void _switchDisplayOrder(int? displayOrder) {
    setState(() => _model.displayOrder = DisplayOrder.values[displayOrder!]);
  }

  @override
  Widget build(BuildContext context) {
    return _mainView(context);
  }

  Widget _mainView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_model.statistics,
                textScaleFactor: 2,
                style: const TextStyle(fontWeight: FontWeight.w100)),
            const Text(""),
            const Text(""),
            (_model.displayOrder == DisplayOrder.eng
                ? Text(_model.engSide,
                    textScaleFactor: 2,
                    style: const TextStyle(fontWeight: FontWeight.w100))
                : Text(_model.heSide,
                    textScaleFactor: 2,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textDirection: TextDirection.rtl)),
            const Text("_________________________________"),
            (_model.displayOrder == DisplayOrder.eng
                ? Text(_model.heSide,
                    textScaleFactor: 2,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textDirection: TextDirection.rtl)
                : Text(_model.engSide,
                    textScaleFactor: 2,
                    style: const TextStyle(fontWeight: FontWeight.w100))),
            const Text(""),
            const Text(""),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: Text(_model.leftSide,
                        textScaleFactor: 2, textDirection: TextDirection.rtl)),
                const Text("   "),
                Expanded(
                    child: Text(_model.rightSide,
                        textScaleFactor: 2,
                        style: const TextStyle(fontWeight: FontWeight.w100)))
              ],
            ),
            const Text(""),
            const Text(""),
            Text(_model.exampleFront,
                textScaleFactor: 2, textDirection: TextDirection.rtl),
            Text(_model.exampleBack,
                textScaleFactor: 2,
                style: const TextStyle(fontWeight: FontWeight.w100)),
          ],
        ),
      ),
      bottomNavigationBar:
          ButtonBar(alignment: MainAxisAlignment.center, children: <Widget>[
        ToggleSwitch(
          totalSwitches: 3,
          labels: const ['He', 'Eng', 'View'],
          onToggle: (index) => _switchDisplayOrder(index),
          initialLabelIndex: _model.displayOrder.index,
        ),
        ToggleSwitch(
          fontSize: 20,
          totalSwitches: 2,
          labels: const ['א', 'אֲ'],
          onToggle: (index) => _switchNikud(index),
          initialLabelIndex: _model.showNikud ? 1 : 0,
        ),
        IndexedStack(
          index: _model.isComplete ? 1 : 0,
          children: [
            ButtonBar(children: <Widget>[
              FloatingActionButton(
                onPressed: _showComplete,
                child: const Text("Show"),
              ),
            ]),
            ButtonBar(
              children: <Widget>[
                FloatingActionButton(
                  onPressed: () => _nextGuess(0),
                  child: const Text("Again"),
                ),
                FloatingActionButton(
                  onPressed: () => _nextGuess(1),
                  child: const Text("Hard"),
                ),
                FloatingActionButton(
                  onPressed: () => _nextGuess(2),
                  child: const Text("Good"),
                ),
                FloatingActionButton(
                  onPressed: () => _nextGuess(3),
                  child: const Text("Easy"),
                ),
              ],
            )
          ],
        ),
      ]),
    );
  }
}
