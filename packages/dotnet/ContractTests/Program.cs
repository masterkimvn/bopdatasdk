using System.Net;
using System.Text;
using BopData;
class Stub : HttpMessageHandler {
 protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage r, CancellationToken token) {
  string path = r.RequestUri!.AbsolutePath;
  if (path.Contains("slow")) return Wait(token);
  var response = new HttpResponseMessage(path.Contains("missing") ? HttpStatusCode.NotFound : HttpStatusCode.OK);
  string body = path.Contains("invalid") ? "{" : path.Contains("wrong") ? "{\"spec\":\"wrong\"}" : path.EndsWith("datasets.json") ? File.ReadAllText("../../tests/fixtures/catalog.json") : File.ReadAllText("../../tests/fixtures/dataset.json");
  response.Content = path.EndsWith(".csv") ? new ByteArrayContent(new byte[]{0xef,0xbb,0xbf,97}) : new StringContent(body,Encoding.UTF8,"application/json");
  return Task.FromResult(response);
 }
 private static async Task<HttpResponseMessage> Wait(CancellationToken t) { await Task.Delay(1000,t); return new(HttpStatusCode.OK); }
}
class Program {
 static async Task Main() {
  using var transport = new HttpClient(new Stub()); using var c = new Client("http://localhost", TimeSpan.FromMilliseconds(50), transport);
  if ((await c.ListDatasetsAsync()).GetProperty("total").GetInt32()!=2) throw new Exception("catalog");
  var d=await c.GetDatasetAsync("test.one"); if (d.GetProperty("provenance").GetProperty("license").GetString()!="synthetic" || d.GetProperty("freshness").GetProperty("lastUpdated").ValueKind!=System.Text.Json.JsonValueKind.Null) throw new Exception("metadata");
  if (!(await c.GetDatasetCsvAsync("test.one")).AsSpan().StartsWith(new byte[]{0xef,0xbb,0xbf})) throw new Exception("csv");
  foreach(var id in new[]{"", "a/b", "abc\n", "đxx", "missing", "invalid", "wrong", "slow"}) { try { await c.GetDatasetAsync(id); throw new Exception("accepted " + id); } catch(BopDataException) {} }
  Console.WriteLine(".NET contract passed");
 }
}
