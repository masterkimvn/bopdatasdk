package ink.bop.data

import java.io.ByteArrayOutputStream
import java.net.HttpURLConnection
import java.net.URI
import java.net.SocketTimeoutException
import org.json.JSONObject

class BopDataException(val kind: String, val status: Int? = null) : Exception(if (status == null) kind else "HTTP $status")

/** Blocking read-only client. Call from a background thread on Android. */
class BopDataClient(baseUrl: String = "https://data.bop.ink", private val timeoutMs: Int = 10000) {
    private val base: String
    init {
        val uri = try { URI(baseUrl) } catch (e: Exception) { throw IllegalArgumentException("Invalid base URL") }
        require((uri.scheme == "http" || uri.scheme == "https") && uri.host != null && uri.userInfo == null && uri.query == null && uri.fragment == null && timeoutMs > 0) { "Invalid client configuration" }
        base = baseUrl.trimEnd('/')
    }
    private fun id(id: String): String {
        if (!Regex("[A-Za-z0-9._-]{3,}").matches(id)) throw BopDataException("invalid_id")
        return id
    }
    private fun request(path: String): ByteArray {
        val connection = URI(base + path).toURL().openConnection() as HttpURLConnection
        connection.requestMethod = "GET"
        connection.connectTimeout = timeoutMs
        connection.readTimeout = timeoutMs
        connection.instanceFollowRedirects = false
        connection.setRequestProperty("User-Agent", "BOPDataSDK/0.1")
        try {
            val status = connection.responseCode
            if (status !in 200..299) throw BopDataException("http", status)
            val out = ByteArrayOutputStream()
            connection.inputStream.use { input ->
                val chunk = ByteArray(8192)
                while (true) {
                    val n = input.read(chunk)
                    if (n < 0) break
                    if (out.size() + n > 8_000_000) throw BopDataException("too_large")
                    out.write(chunk, 0, n)
                }
            }
            return out.toByteArray()
        } catch (e: BopDataException) { throw e }
        catch (e: SocketTimeoutException) { throw BopDataException("timeout") }
        catch (e: java.io.IOException) { throw BopDataException("transport") }
        finally { connection.disconnect() }
    }
    private fun json(path: String, spec: String): JSONObject {
        val raw = request(path)
        val result = try { JSONObject(String(raw, Charsets.UTF_8)) } catch (e: org.json.JSONException) { throw BopDataException("json") }
        if (result.optString("spec") != spec) throw BopDataException("spec")
        return result
    }
    fun listDatasets(): JSONObject = json("/api/v1/datasets.json", "bop.catalog/1")
    fun getDataset(id: String): JSONObject = json("/api/v1/datasets/${id(id)}.json", "bop.dataset/1")
    fun getDatasetCsv(id: String): ByteArray = request("/api/v1/datasets/${id(id)}.csv")
}
