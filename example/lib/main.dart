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
  bool withDecoder = false;

  final focusNode = FocusNode();
  String? scanned;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: withDecoder
          ? Scanner.barcode(
              focusNode: focusNode,
              onDecoded: (plu, price, kgs) {
                setState(() {
                  scanned = '$plu, $price, $kgs';
                });
              },
              child: Center(
                child: Text('Scanned: $scanned'),
              ))
          : Scanner(
              focusNode: focusNode,
              onScanned: (value) {
                setState(() {
                  scanned = value;
                });
              },
              child: Center(
                child: Text('Scanned: $scanned'),
              )),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              withDecoder = !withDecoder;
            });
          },
          label: Text('Switch to ${withDecoder ? 'Scanner' : 'Barcode'}')),
    );
  }
}
