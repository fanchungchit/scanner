import 'package:flutter/material.dart';
import 'package:scanner/scanner.dart';

class BarcodeScannerDebugView extends StatefulWidget {
  const BarcodeScannerDebugView({super.key});

  @override
  State<BarcodeScannerDebugView> createState() =>
      _BarcodeScannerDebugViewState();
}

class _BarcodeScannerDebugViewState extends State<BarcodeScannerDebugView> {
  final List<(String, DateTime)> barcodes = [];

  onBarcodeScan(String barcode) {
    setState(() {
      barcodes.insert(0, (barcode, DateTime.now()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BarcodeScanner(
        onBarcodeScan: onBarcodeScan,
        child: Scaffold(
          appBar: AppBar(title: const Text('掃描器測試')),
          body: Column(
            children: [
              ListTile(
                title: const Text('掃描次數'),
                subtitle: Text('${barcodes.length}'),
              ),
              ListTile(
                title: TextButton(
                  onPressed: () => setState(() {
                    barcodes.clear();
                  }),
                  child: const Text('清除掃描紀錄'),
                ),
              ),
              const ListTile(title: Text('掃描紀錄')),
              Expanded(
                  child: ListView.builder(
                itemCount: barcodes.length,
                itemBuilder: (context, index) {
                  final barcode = barcodes[index];
                  return ListTile(
                    title: Text(barcode.$1),
                    subtitle: Text(barcode.$2.toString()),
                  );
                },
              ))
            ],
          ),
        ));
  }
}
