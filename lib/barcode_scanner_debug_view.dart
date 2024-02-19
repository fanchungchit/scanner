import 'package:flutter/material.dart';

enum BarcodeScannerDebugViewMode {
  character,
  logicalKey,
  physicalKey,
  data,
}

class BarcodeScannerDebugView extends StatefulWidget {
  const BarcodeScannerDebugView({super.key});

  @override
  State<BarcodeScannerDebugView> createState() =>
      _BarcodeScannerDebugViewState();
}

class _BarcodeScannerDebugViewState extends State<BarcodeScannerDebugView> {
  final focusNode = FocusNode();
  bool hasFocus = false;
  bool hasPrimaryFocus = false;
  bool canRequestFocus = false;
  final events = <RawKeyEvent>[];
  BarcodeScannerDebugViewMode mode = BarcodeScannerDebugViewMode.character;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {
        hasFocus = focusNode.hasFocus;
        hasPrimaryFocus = focusNode.hasPrimaryFocus;
        canRequestFocus = focusNode.canRequestFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barcode Scanner Debug')),
      body: Focus(
        autofocus: true,
        focusNode: focusNode,
        onKey: (node, event) {
          setState(() {
            events.add(event);
          });
          return KeyEventResult.ignored;
        },
        child: ListView(
          children: [
            ListTile(
              title: const Text('hasFocus'),
              subtitle: Text(hasFocus.toString()),
              trailing: TextButton(
                onPressed: () => focusNode.requestFocus(),
                child: const Text('requestFocus'),
              ),
            ),
            ListTile(
              title: const Text('hasPrimaryFocus'),
              subtitle: Text(hasPrimaryFocus.toString()),
            ),
            ListTile(
              title: const Text('canRequestFocus'),
              subtitle: Text(canRequestFocus.toString()),
            ),
            ListTile(
              title: const Text('mode'),
              subtitle: DropdownButton<BarcodeScannerDebugViewMode>(
                value: mode,
                items: BarcodeScannerDebugViewMode.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.toString().split('.').last),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => mode = value!),
              ),
            ),
            ListTile(
              title: const Text('events'),
              subtitle: Text(events.map((e) {
                switch (mode) {
                  case BarcodeScannerDebugViewMode.character:
                    return e.character;
                  case BarcodeScannerDebugViewMode.logicalKey:
                    return e.logicalKey.debugName;
                  case BarcodeScannerDebugViewMode.physicalKey:
                    return e.physicalKey.debugName;
                  case BarcodeScannerDebugViewMode.data:
                    return e.data;
                }
              }).join(', ')),
              trailing: TextButton(
                onPressed: () {
                  setState(() {
                    events.clear();
                  });
                },
                child: const Text('clear'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
