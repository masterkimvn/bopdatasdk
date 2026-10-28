# .NET client

A read-only .NET 8 client under development. Build with `dotnet pack`; the package is not published. `BopData.Client` provides asynchronous `ListDatasetsAsync`, `GetDatasetAsync`, and `GetDatasetCsvAsync`; JSON is returned as `JsonElement` and CSV as bytes. Requests accept cancellation tokens and default to a ten-second timeout and an 8 MB response limit. Use `Dispose` when finished.
