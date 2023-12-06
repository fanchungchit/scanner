import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:scanner/scanner.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainView(),
    );
  }
}

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  bool withDecoder = false;

  final focusNode = FocusNode();
  var isFocused = false;
  RawKeyEvent? rawkeyEvent;
  KeyEvent? keyEvent;
  String? scanned;
  List<RawKeyEvent> rawkeyEvents = [];
  List<KeyEvent> events = [];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BarcodeScanner(
          onFocusChange: (isFocused) =>
              setState(() => this.isFocused = isFocused),
          focusNode: focusNode,
          onKey: (node, event) {
            if (event is RawKeyUpEvent) {}
          },
          onBarcode: (barcode) {
            setState(() {
              scanned = barcode;
            });
          },
          onEvents: (events) => setState(() {
                rawkeyEvents = events;
              }),
          child: GestureDetector(
            onTap: () => focusNode.requestFocus(),
            behavior: HitTestBehavior.opaque,
            child: Scaffold(
              appBar: AppBar(
                title: const TextField(),
              ),
              body: ListView(
                children: [
                  Text('Focused: $isFocused'),
                  Text('Scanned: $scanned'),
                  Text('Key: ${rawkeyEvent?.toString() ?? ''}'),
                  Text('KeyEvent:\n${keyEvent?.toString() ?? ''}'),
                  TextButton(
                      onPressed: () => setState(() {
                            rawkeyEvents.clear();
                          }),
                      child: const Text('Clear')),
                  Text(
                      'Events: ${rawkeyEvents.map((e) => e.toString()).join('\n')}'),
                ],
              ),
            ),
          )),
    );
  }
}
