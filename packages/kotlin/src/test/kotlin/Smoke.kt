import ink.bop.data.BopDataClient
import ink.bop.data.BopDataException
fun main() {
  val c = BopDataClient("http://127.0.0.1:18765")
  check(c.listDatasets().getInt("total") == 2)
  val d = c.getDataset("test.one")
  check(d.getJSONObject("provenance").getString("license") == "synthetic")
  check(c.getDatasetCsv("test.one").take(3) == listOf(0xef.toByte(), 0xbb.toByte(), 0xbf.toByte()))
  for (bad in listOf("", "a/b", "abc\n", "đxx", "status404", "invalid", "wrong")) {
    try { c.getDataset(bad); error("accepted invalid input") } catch (_: BopDataException) {}
  }
  println("Kotlin contract passed")
}
