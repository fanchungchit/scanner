import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({
    super.key,
    this.autoFocus = true,
    this.focusNode,
    this.onFocusChange,
    this.onKey,
    this.onKeyEvent,
    this.onBarcode,
    this.onEvents,
    required this.child,
  });

  final bool autoFocus;
  final FocusNode? focusNode;
  final void Function(bool)? onFocusChange;
  final void Function(FocusNode, RawKeyEvent)? onKey;
  final KeyEventResult Function(FocusNode, KeyEvent)? onKeyEvent;
  final void Function(String barcode)? onBarcode;
  final void Function(List<RawKeyEvent> events)? onEvents;
  final Widget child;

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  final events = <RawKeyEvent>[];

  String get barcode {
    final buffer = StringBuffer();
    for (final event in events) {
      if (event.character == null) continue;
      if (event.isShiftPressed) continue;
      final index = events.indexOf(event);
      if (index != 0) {
        final previous = events[index - 1];
        if (previous.isShiftPressed) {
          buffer.write(event.character!.toUpperCase());
          continue;
        }
      }
      buffer.write(event.character);
    }
    return buffer.toString();
  }

  addEvent(RawKeyEvent event) {
    if (event is RawKeyUpEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      widget.onBarcode?.call(barcode);
      events.clear();
    } else {
      events.add(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autoFocus,
      focusNode: widget.focusNode,
      onFocusChange: widget.onFocusChange,
      onKey: (node, event) {
        widget.onKey?.call(node, event);
        widget.onEvents?.call(events);
        addEvent(event);
        return KeyEventResult.ignored;
      },
      onKeyEvent: widget.onKeyEvent,
      child: widget.child,
    );
  }
}
