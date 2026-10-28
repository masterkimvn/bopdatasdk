using BopData;
using var client = new Client();
var catalog = await client.ListDatasetsAsync();
var id = catalog.GetProperty("datasets")[0].GetProperty("canonicalId").GetString()!;
var dataset = await client.GetDatasetAsync(id);
Console.WriteLine(dataset.GetProperty("freshness"));
Console.WriteLine(dataset.GetProperty("provenance"));
