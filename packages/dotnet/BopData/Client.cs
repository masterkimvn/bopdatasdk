using System.Net;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace BopData;

public sealed class BopDataException : Exception
{
    public string Kind { get; }
    public int? Status { get; }
    public BopDataException(string kind, int? status = null) : base(status is null ? kind : $"HTTP {status}") => (Kind, Status) = (kind, status);
}

public sealed class Client : IDisposable
{
    private readonly HttpClient http;
    private readonly string baseUrl;
    private readonly bool ownsClient;
    private const int MaxBytes = 8_000_000;
    public Client(string baseUrl = "https://data.bop.ink", TimeSpan? timeout = null, HttpClient? transport = null)
    {
        if (!Uri.TryCreate(baseUrl, UriKind.Absolute, out var uri) || (uri.Scheme != "https" && uri.Scheme != "http") || uri.UserInfo.Length > 0 || uri.Query.Length > 0 || uri.Fragment.Length > 0) throw new ArgumentException("Invalid base URL");
        var duration = timeout ?? TimeSpan.FromSeconds(10);
        if (duration <= TimeSpan.Zero) throw new ArgumentException("Invalid timeout");
        this.baseUrl = baseUrl.TrimEnd('/');
        ownsClient = transport is null;
        http = transport ?? new HttpClient(new HttpClientHandler { AllowAutoRedirect = false });
        Timeout = duration;
    }
    public TimeSpan Timeout { get; }
    private static string Id(string id) => id is not null && Regex.IsMatch(id, "\\A[A-Za-z0-9._-]{3,}\\z", RegexOptions.CultureInvariant) ? id : throw new BopDataException("invalid_id");
    private async Task<byte[]> Request(string path, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(Timeout);
        try
        {
            using var request = new HttpRequestMessage(HttpMethod.Get, baseUrl + path);
            request.Headers.TryAddWithoutValidation("User-Agent", "BOPDataSDK/0.1");
            using var response = await http.SendAsync(request, HttpCompletionOption.ResponseHeadersRead, cts.Token).ConfigureAwait(false);
            if (!response.IsSuccessStatusCode) throw new BopDataException("http", (int)response.StatusCode);
            if (response.Content.Headers.ContentLength > MaxBytes) throw new BopDataException("too_large");
            await using var source = await response.Content.ReadAsStreamAsync(cts.Token).ConfigureAwait(false);
            using var destination = new MemoryStream();
            var buffer = new byte[8192];
            int count;
            while ((count = await source.ReadAsync(buffer, cts.Token).ConfigureAwait(false)) > 0)
            {
                if (destination.Length + count > MaxBytes) throw new BopDataException("too_large");
                destination.Write(buffer, 0, count);
            }
            return destination.ToArray();
        }
        catch (OperationCanceledException) when (!cancellationToken.IsCancellationRequested) { throw new BopDataException("timeout"); }
        catch (HttpRequestException) { throw new BopDataException("transport"); }
        catch (IOException) { throw new BopDataException("transport"); }
    }
    private async Task<JsonElement> Json(string path, string spec, CancellationToken ct)
    {
        var bytes = await Request(path, ct).ConfigureAwait(false);
        JsonDocument doc;
        try { doc = JsonDocument.Parse(bytes); } catch (JsonException) { throw new BopDataException("json"); }
        using (doc)
        {
            var root = doc.RootElement;
            if (root.ValueKind != JsonValueKind.Object || !root.TryGetProperty("spec", out var value) || value.ValueKind != JsonValueKind.String || value.GetString() != spec) throw new BopDataException("spec");
            return root.Clone();
        }
    }
    public Task<JsonElement> ListDatasetsAsync(CancellationToken ct = default) => Json("/api/v1/datasets.json", "bop.catalog/1", ct);
    public Task<JsonElement> GetDatasetAsync(string id, CancellationToken ct = default) => Json($"/api/v1/datasets/{Id(id)}.json", "bop.dataset/1", ct);
    public Task<byte[]> GetDatasetCsvAsync(string id, CancellationToken ct = default) => Request($"/api/v1/datasets/{Id(id)}.csv", ct);
    public void Dispose() { if (ownsClient) http.Dispose(); }
}
