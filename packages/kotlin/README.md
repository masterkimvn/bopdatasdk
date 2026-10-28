# Kotlin client

A blocking Kotlin/JVM client designed for Android and the JVM. Call it from a background thread on Android and add the INTERNET permission. It provides `listDatasets()`, `getDataset(id)` and `getDatasetCsv(id)`, returning JSON objects or CSV bytes. It uses `org.json`; Android supplies this API, while JVM applications need an `org.json` dependency. The package is in development and has not been published.
