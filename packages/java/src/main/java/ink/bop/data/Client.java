package ink.bop.data;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

/** Read-only client for the BOP Data API. */
public final class Client {
    private final URI base;
    private final Duration timeout;
    private final HttpClient http;
    private static final ObjectMapper JSON = new ObjectMapper();
    public Client() { this(URI.create("https://data.bop.ink"), Duration.ofSeconds(10)); }
    public Client(URI base, Duration timeout) {
        if (base == null || !("https".equals(base.getScheme()) || "http".equals(base.getScheme())) || base.getHost() == null || base.getUserInfo() != null || base.getQuery() != null || base.getFragment() != null || timeout == null || timeout.isZero() || timeout.isNegative()) throw new IllegalArgumentException("Invalid client configuration");
        this.base = URI.create(base.toString().replaceAll("/+$", "")); this.timeout = timeout;
        this.http = HttpClient.newBuilder().connectTimeout(timeout).followRedirects(HttpClient.Redirect.NEVER).build();
    }
    private String id(String id) {
        if (id == null || !id.matches("[A-Za-z0-9._-]{3,}")) throw new IllegalArgumentException("Invalid canonical ID");
        return id;
    }
    private byte[] request(String path) throws IOException, InterruptedException {
        HttpRequest req = HttpRequest.newBuilder(URI.create(base.toString() + path)).timeout(timeout).header("User-Agent", "BOPDataSDK/0.1").GET().build();
        HttpResponse<byte[]> r = http.send(req, HttpResponse.BodyHandlers.ofByteArray());
        if (r.statusCode() < 200 || r.statusCode() >= 300) throw new IOException("HTTP " + r.statusCode());
        return r.body();
    }
    private JsonNode json(String path, String spec) throws IOException, InterruptedException {
        JsonNode result = JSON.readTree(request(path));
        if (result == null || !result.isObject() || !spec.equals(result.path("spec").asText())) throw new IOException("Incompatible response spec");
        return result;
    }
    public JsonNode listDatasets() throws IOException, InterruptedException { return json("/api/v1/datasets.json", "bop.catalog/1"); }
    public JsonNode getDataset(String id) throws IOException, InterruptedException { return json("/api/v1/datasets/" + id(id) + ".json", "bop.dataset/1"); }
    public byte[] getDatasetCsv(String id) throws IOException, InterruptedException { return request("/api/v1/datasets/" + id(id) + ".csv"); }
}
