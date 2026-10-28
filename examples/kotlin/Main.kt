import ink.bop.data.BopDataClient
fun main() {
    val client = BopDataClient()
    val first = client.listDatasets().getJSONArray("datasets").getJSONObject(0)
    val dataset = client.getDataset(first.getString("canonicalId"))
    println(dataset.opt("freshness"))
    println(dataset.opt("provenance"))
}
