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
      final character = event.logicalKey.keyLabel;
      final index = events.indexOf(event);
      if (index != 0) {
        final previousEvent = events.elementAtOrNull(index - 1);
        if (previousEvent?.logicalKey == LogicalKeyboardKey.shiftLeft) {
          buffer.write(character.toUpperCase());
          continue;
        }
      }
      buffer.write(character);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autoFocus,
      focusNode: widget.focusNode,
      onFocusChange: widget.onFocusChange,
      onKey: (node, event) {
        widget.onKey?.call(node, event);
        if (event is RawKeyUpEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            widget.onBarcode?.call(barcode);
            events.clear();
          } else {
            events.add(event);
          }
        }
        widget.onEvents?.call(events);
        return KeyEventResult.handled;
      },
      onKeyEvent: widget.onKeyEvent,
      child: widget.child,
    );
  }
}
