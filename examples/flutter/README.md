# Flutter BOP Data example

From this directory run `flutter pub get` and `flutter run` on an Android or iOS device or simulator. The app reads the catalog, fetches its first dataset, and displays its data, freshness and provenance. Loading and connection errors are shown in the app. The local Dart SDK package is used through a path dependency and is not published.

`flutter analyze` and `flutter test` have been run on Linux. Android and iOS builds and device operation have not yet been verified. Flutter web requires an upstream CORS policy that allows the app's origin.
