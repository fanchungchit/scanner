import 'package:flutter/material.dart';

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
  final focusNode = FocusNode();
  String? scanned;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scanner(
          focusNode: focusNode,
          onScanned: (value) {
            setState(() {
              scanned = value;
            });
          },
          child: Center(
            child: Text('Scanned: $scanned'),
          )),
    );
  }
}
