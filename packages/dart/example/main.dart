import 'package:bop_data_sdk/bop_data.dart';

Future<void> main() async {
  final c = BopDataClient();
  try {
    final catalog = await c.listDatasets();
    final dataset = await c.getDataset(catalog['datasets'][0]['canonicalId']);
    print(dataset['freshness']);
    print(dataset['provenance']);
  } finally {
    c.close();
  }
}
