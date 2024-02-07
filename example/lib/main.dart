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
  String? data;

  @override
  Widget build(BuildContext context) {
    return BarcodeScanner(
        onBarcode: (barcode) => setState(() => data = barcode),
        onKey: (focus, event) {
          if (event is RawKeyUpEvent) return;
          if (event.isShiftPressed) print('Shift pressed');
          print(event.character);
        },
        child: Scaffold(
          body: Center(child: Text(data ?? 'Start scanning...')),
        ));
  }
}
