library scanner;

import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;

import 'package:collection/collection.dart';

typedef OnScanned = void Function(String barcode);
typedef OnDecoded = void Function(String plu, double? price, double? kilograms);

String _parsePlu(String barcode) {
  return barcode.substring(2, 7);
}

double? _parsePrice(String barcode) {
  final integer = barcode.substring(7, 10);
  final decimal = barcode.substring(10, 12);
  return double.tryParse('$integer.$decimal');
}

double? _parseKilograms(String barcode) {
  final integer = barcode.substring(12, 14);
  final decimal = barcode.substring(14, 17);
  return double.tryParse('$integer.$decimal');
}

/// A widget that listens for keyboard events and debounces them.
class Scanner extends StatefulWidget {
  const Scanner({
    super.key,
    this.debounce = const Duration(milliseconds: 100),
    required this.focusNode,
    this.autoFocus = true,
    required this.onScanned,
    required this.child,
  });

  /// The debounce duration.
  final Duration debounce;

  /// The focus node.
  final FocusNode focusNode;

  /// Whether to autofocus the focus node.
  final bool autoFocus;

  /// The callback that is called when a scan is detected.
  final OnScanned onScanned;

  /// The child widget.
  final Widget child;

  factory Scanner.barcode({
    Key? key,
    Duration debounce = const Duration(milliseconds: 100),
    required FocusNode focusNode,
    bool autoFocus = true,
    required OnDecoded onDecoded,
    required Widget child,
  }) {
    return Scanner(
      key: key,
      debounce: debounce,
      focusNode: focusNode,
      autoFocus: autoFocus,
      onScanned: (barcode) {
        if (barcode.length == 18 && barcode.startsWith('22')) {
          final plu = _parsePlu(barcode);
          final quantity = _parsePrice(barcode);
          final kilograms = _parseKilograms(barcode);
          return onDecoded(plu, quantity, kilograms);
        }
        return onDecoded(barcode, null, null);
      },
      child: child,
    );
  }

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  /// The events that are debounced.
  final _events = <KeyEvent>[];

  /// The debounce timer.
  Timer? _debounceTimer;

  String get _scanned {
    final stringBuffer = StringBuffer();
    for (final event in _events) {
      if (event.character == null) continue;
      final index = _events.indexOf(event);
      if (index != 0) {
        final previousEvent = _events.elementAtOrNull(index - 1);
        if (previousEvent?.logicalKey == LogicalKeyboardKey.shiftLeft) {
          stringBuffer.write(event.logicalKey.keyLabel.toUpperCase());
          continue;
        }
      }
      stringBuffer.write(event.logicalKey.keyLabel.toLowerCase());
    }
    return stringBuffer.toString();
  }

  void _debouncing({required KeyEvent event}) {
    _events.add(event);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounce, () {
      widget.onScanned(_scanned);
      _events.clear();
    });
  }

  void _onKeyEvent(KeyEvent event) {
    /// If the focus node doesn't have focus, request it.
    if (!widget.focusNode.hasFocus) widget.focusNode.requestFocus();

    /// Group events by debounce duration.
    _debouncing(event: event);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: widget.focusNode,
      autofocus: widget.autoFocus,
      onKeyEvent: _onKeyEvent,
      child: widget.child,
    );
  }
}
