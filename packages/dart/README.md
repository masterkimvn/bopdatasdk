# Dart client

Source package under development; not published. Run `dart pub get`, `dart test`, and `dart run example/main.dart`. Methods `listDatasets`, `getDataset`, and `getDatasetCsv` return JSON maps or raw CSV bytes. Requests use a 10-second default timeout and an 8 MB response limit. Browser use requires provider CORS permission; native/server use does not use browser CORS.
