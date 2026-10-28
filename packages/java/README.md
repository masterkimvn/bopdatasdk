# Java client

This package is under development and not published. Requires Java 11 or later and Maven. Build with `mvn test package`; use `ink.bop.data.Client` and call `listDatasets`, `getDataset`, or `getDatasetCsv`. JSON responses are Jackson `JsonNode` objects, preserving additional fields; CSV returns raw bytes. See `examples/java/Main.java`.
