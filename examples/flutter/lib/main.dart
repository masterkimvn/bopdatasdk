import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:bop_data_sdk/bop_data.dart';

Future<Map<String, dynamic>> loadDataset() async {
  final client = BopDataClient();
  try {
    final catalog = await client.listDatasets();
    final entries = catalog['datasets'] as List;
    if (entries.isEmpty) throw StateError('The catalog is empty');
    return await client.getDataset(entries.first['canonicalId'] as String);
  } finally {
    client.close();
  }
}

void main() => runApp(const BopDataApp());

class BopDataApp extends StatelessWidget {
  final Future<Map<String, dynamic>> Function()? loader;
  const BopDataApp({super.key, this.loader});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'BOP Data',
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: DatasetScreen(loader: loader ?? loadDataset),
      );
}

class DatasetScreen extends StatefulWidget {
  final Future<Map<String, dynamic>> Function() loader;
  const DatasetScreen({super.key, required this.loader});
  @override
  State<DatasetScreen> createState() => _DatasetScreenState();
}

class _DatasetScreenState extends State<DatasetScreen> {
  late Future<Map<String, dynamic>> _dataset;
  @override
  void initState() {
    super.initState();
    _dataset = widget.loader();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('BOP Data')),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _dataset,
          builder: (context, snapshot) {
            if (!snapshot.hasData && !snapshot.hasError) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Unable to load the dataset.'),
                    TextButton(
                      onPressed: () => setState(() {
                        _dataset = widget.loader();
                      }),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            final dataset = snapshot.data!;
            const encoder = JsonEncoder.withIndent('  ');
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  dataset['canonicalId']?.toString() ?? 'Dataset',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                for (final key in [
                  'identity',
                  'data',
                  'freshness',
                  'provenance',
                ]) ...[
                  const SizedBox(height: 16),
                  Text(key, style: Theme.of(context).textTheme.titleMedium),
                  SelectableText(encoder.convert(dataset[key])),
                ],
              ],
            );
          },
        ),
      );
}
