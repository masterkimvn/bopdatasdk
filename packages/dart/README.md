# BOP Data SDK for Dart / Flutter

Read-only connector to [BOP Data](https://data.bop.ink), the non-profit, ad-free structured dataset initiative.

After the first version has actually been published on pub.dev: `dart pub add bop_data_sdk`.

```dart
import 'package:bop_data_sdk/bop_data.dart';

Future<void> main() async {
  final client = BopDataClient();
  try {
    final catalog = await client.listDatasets();
    final data = await client.getDataset(catalog['datasets'][0]['canonicalId']);
    print(data['data']);
  } finally {
    client.close();
  }
}
```

CSV is returned as bytes; browser cross-origin use requires CORS. Credit source datasets as **BOP Data**. SDK software is MIT licensed; dataset rights differ.
