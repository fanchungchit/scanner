library scanner;

import 'dart:async' show Timer;
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show KeyDownEvent, LogicalKeyboardKey;

import 'package:collection/collection.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';

/// Define the input type.
enum ScannerInputType {
  debounce,
  enter,
}

/// The default debounce duration.
const _debounce = Duration(milliseconds: 50);

typedef OnScanned = void Function(String barcode);
typedef OnDecoded = void Function(String plu, double? price, double? kilograms);

/// Return the PLU from a barcode.
String _parsePlu(String barcode) {
  return barcode.substring(2, 7);
}

/// Return the price from a barcode.
double? _parsePrice(String barcode) {
  final integer = barcode.substring(7, 10);
  final decimal = barcode.substring(10, 12);
  return double.tryParse('$integer.$decimal');
}

/// Return the kilograms from a barcode.
double? _parseKilograms(String barcode) {
  final integer = barcode.substring(12, 14);
  final decimal = barcode.substring(14, 17);
  return double.tryParse('$integer.$decimal');
}

/// A widget that listens for keyboard events and debounces them.
class Scanner extends StatefulWidget {
  const Scanner({
    super.key,
    this.inputType = ScannerInputType.enter,
    this.debounce = _debounce,
    required this.focusNode,
    this.autoFocus = true,
    required this.onScanned,
    required this.child,
  });

  /// The input type.
  final ScannerInputType inputType;

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

  /// With this constructor, the scanner will return with decoded data.
  factory Scanner.barcode({
    Key? key,
    ScannerInputType inputType = ScannerInputType.enter,
    Duration debounce = _debounce,
    required FocusNode focusNode,
    bool autoFocus = true,
    required OnDecoded onDecoded,
    required Widget child,
  }) {
    return Scanner(
      key: key,
      inputType: inputType,
      debounce: debounce,
      focusNode: focusNode,
      autoFocus: autoFocus,
      onScanned: (barcode) {
        /// Return data from custom barcode
        if (barcode.length == 18) {
          final plu = _parsePlu(barcode);
          final price = _parsePrice(barcode);
          final kilograms = _parseKilograms(barcode);
          return onDecoded(plu, price, kilograms);
        }

        /// Return data from EAN-13 barcode
        return onDecoded(barcode, null, null);
      },
      child: child,
    );
  }

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  /// Whether the scanner is supported.
  bool isHoneywellSupported = false;
  HoneywellScanner? honeywellScanner;

  /// The events that are debounced.
  final _events = <KeyEvent>[];

  /// The debounce timer.
  Timer? _debounceTimer;

  /// Return the scanned string.
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

  /// Debounce the events.
  void _debouncing({required KeyEvent event}) {
    _events.add(event);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounce, () {
      widget.onScanned(_scanned);
      _events.clear();
    });
  }

  /// Handle the key events.
  void _onKeyEvent(KeyEvent event) {
    /// If the focus node doesn't have focus, request it.
    // if (!widget.focusNode.hasFocus) widget.focusNode.requestFocus();

    switch (widget.inputType) {
      case ScannerInputType.debounce:

        /// Group events by debounce duration.
        _debouncing(event: event);
        break;

      case ScannerInputType.enter:
        if (event is! KeyDownEvent) return;
        _events.add(event);

        /// If the event is a enter event, return.
        if (event.logicalKey == LogicalKeyboardKey.enter) {
          widget.onScanned(_scanned);
          _events.clear();
        }
        break;
    }
  }

  init() async {
    if (kIsWeb) return;
    isHoneywellSupported = await HoneywellScanner().isSupported();
    honeywellScanner = HoneywellScanner(onScannerDecodeCallback: (scannedData) {
      widget.onScanned(scannedData?.code ?? '');
    }, onScannerErrorCallback: (error) {
      log('Scanner error: $error');
    });
    await honeywellScanner?.startScanner();
    final properties = {
      'DEC_CODABAR_START_STOP_TRANSMIT': true,
      'DEC_EAN13_CHECK_DIGIT_TRANSMIT': true,
      'DEC_UPCA_CHECK_DIGIT_TRANSMIT': true,
    };
    honeywellScanner?.setProperties(properties);
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    honeywellScanner?.stopScanner();
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
