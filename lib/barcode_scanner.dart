import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef OnBarcodeScan = void Function(String barcode);

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner(
      {super.key, required this.onBarcodeScan, required this.child});

  final OnBarcodeScan onBarcodeScan;
  final Widget child;

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  final _hk = HardwareKeyboard.instance;
  final _characters = <String>[];

  @override
  void initState() {
    _hk.addHandler(_handler);
    super.initState();
  }

  @override
  void dispose() {
    _hk.removeHandler(_handler);
    super.dispose();
  }

  bool _handler(KeyEvent event) {
    if (_hk.isLogicalKeyPressed(LogicalKeyboardKey.enter)) {
      _fire();
      return false;
    }

    final character = event.character;
    if (character == null) return false;

    _add(character);
    return false;
  }

  _fire() {
    final value = _characters.join();
    _characters.clear();
    widget.onBarcodeScan(value);
  }

  _add(String character) {
    _characters.add(character);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
