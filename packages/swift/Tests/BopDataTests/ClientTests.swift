import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import BopData

final class MockURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        let path = request.url!.path
        let code = path.contains("missing") ? 404 : 200
        let body: Data
        if path.hasSuffix(".csv") { body = Data([0xef, 0xbb, 0xbf, 97]) }
        else if path.contains("invalid") { body = Data("{".utf8) }
        else if path.contains("wrong") { body = Data("{\"spec\":\"wrong\"}".utf8) }
        else if path.hasSuffix("datasets.json") { body = Data("{\"spec\":\"bop.catalog/1\",\"total\":2}".utf8) }
        else { body = Data("{\"spec\":\"bop.dataset/1\",\"freshness\":{\"lastUpdated\":null},\"provenance\":{\"license\":\"synthetic\"},\"future\":\"preserved\"}".utf8) }
        let response = HTTPURLResponse(url: request.url!, statusCode: code, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: body)
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}
final class ClientTests: XCTestCase {
    func testContract() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let c = try BopDataClient(baseURL: "http://localhost", session: URLSession(configuration: config))
        let catalog = try await c.listDatasets(); XCTAssertEqual(catalog["total"] as? Int, 2)
        let data = try await c.getDataset("test.one")
        XCTAssertEqual(data["future"] as? String, "preserved")
        XCTAssertEqual((data["provenance"] as? [String: String])?["license"], "synthetic")
        let csv = try await c.getDatasetCSV("test.one"); XCTAssertEqual(Array(csv.prefix(3)), [0xef, 0xbb, 0xbf])
        for id in ["", "a/b", "abc\n", "đxx", "missing", "invalid", "wrong"] {
            do { _ = try await c.getDataset(id); XCTFail("accepted \(id)") } catch is BopDataError {} catch { XCTFail("unexpected error") }
        }
    }
}
