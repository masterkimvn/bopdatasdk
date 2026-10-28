import SwiftUI
import BopData

struct DatasetView: View {
    @State private var display = "Loading…"
    var body: some View {
        ScrollView { Text(display).textSelection(.enabled) }
            .task {
                do {
                    let client = try BopDataClient()
                    let catalog = try await client.listDatasets()
                    guard let entries = catalog["datasets"] as? [[String: Any]], let id = entries.first?["canonicalId"] as? String else { display = "No datasets available"; return }
                    let dataset = try await client.getDataset(id)
                    display = "\(id)\n\(dataset["data"] ?? "")\n\(dataset["freshness"] ?? "")\n\(dataset["provenance"] ?? "")"
                } catch { display = "Unable to load data: \(error)" }
            }
    }
}
