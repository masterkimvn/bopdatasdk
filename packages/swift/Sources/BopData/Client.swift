import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum BopDataError: Error {
    case invalidConfiguration, invalidID, http(Int), transport, timeout, tooLarge, json, spec
}

private final class NoRedirect: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) { completionHandler(nil) }
}

public final class BopDataClient {
    private let base: String
    private let session: URLSession
    private let timeout: TimeInterval
    private let maxBytes = 8_000_000
    public init(baseURL: String = "https://data.bop.ink", timeout: TimeInterval = 10, session: URLSession? = nil) throws {
        guard let u = URLComponents(string: baseURL), ["https", "http"].contains(u.scheme ?? ""), u.host != nil, u.user == nil, u.password == nil, u.query == nil, u.fragment == nil, timeout > 0 else { throw BopDataError.invalidConfiguration }
        self.base = baseURL.replacingOccurrences(of: "/+$", with: "", options: .regularExpression)
        self.timeout = timeout
        self.session = session ?? URLSession(configuration: .ephemeral, delegate: NoRedirect(), delegateQueue: nil)
    }
    private func path(_ id: String, _ ext: String) throws -> String {
        guard id.range(of: "\\A[A-Za-z0-9._-]{3,}\\z", options: .regularExpression) != nil else { throw BopDataError.invalidID }
        return "/api/v1/datasets/\(id).\(ext)"
    }
    private func request(_ path: String) async throws -> Data {
        guard let url = URL(string: base + path) else { throw BopDataError.invalidConfiguration }
        var req = URLRequest(url: url, timeoutInterval: timeout)
        req.httpMethod = "GET"
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await withCheckedThrowingContinuation { continuation in
                session.dataTask(with: req) { data, response, error in
                    if let error = error { continuation.resume(throwing: error) }
                    else if let data = data, let response = response { continuation.resume(returning: (data, response)) }
                    else { continuation.resume(throwing: BopDataError.transport) }
                }.resume()
            }
        }
        catch let e as URLError where e.code == .timedOut { throw BopDataError.timeout }
        catch { throw BopDataError.transport }
        guard let res = response as? HTTPURLResponse else { throw BopDataError.transport }
        guard (200...299).contains(res.statusCode) else { throw BopDataError.http(res.statusCode) }
        guard data.count <= maxBytes else { throw BopDataError.tooLarge }
        return data
    }
    private func json(_ path: String, _ spec: String) async throws -> [String: Any] {
        let data = try await request(path)
        guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { throw BopDataError.json }
        guard obj["spec"] as? String == spec else { throw BopDataError.spec }
        return obj
    }
    public func listDatasets() async throws -> [String: Any] { try await json("/api/v1/datasets.json", "bop.catalog/1") }
    public func getDataset(_ id: String) async throws -> [String: Any] { try await json(path(id, "json"), "bop.dataset/1") }
    public func getDatasetCSV(_ id: String) async throws -> Data { try await request(path(id, "csv")) }
}
