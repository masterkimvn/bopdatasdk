package ink.bop.data;
import com.sun.net.httpserver.HttpServer;
import org.junit.jupiter.api.Test;
import java.net.InetSocketAddress;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import static org.junit.jupiter.api.Assertions.*;
class ClientTest {
 @Test void contract() throws Exception {
  HttpServer server = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
  server.createContext("/", x -> {
   String path=x.getRequestURI().getPath(); int status=path.contains("missing")?404:200;
   byte[] b = path.endsWith(".csv") ? new byte[]{(byte)0xef,(byte)0xbb,(byte)0xbf,'a',',','b'} : Files.readAllBytes(Path.of("../../tests/fixtures/"+(path.endsWith("datasets.json")?"catalog.json":"dataset.json")));
   x.sendResponseHeaders(status,b.length); x.getResponseBody().write(b); x.close();
  }); server.start();
  try {
   Client c=new Client(URI.create("http://127.0.0.1:"+server.getAddress().getPort()),Duration.ofSeconds(2));
   assertEquals(2,c.listDatasets().get("total").asInt());
   var d=c.getDataset("test.one"); assertEquals("preserved",d.get("future").asText()); assertTrue(d.get("freshness").get("lastUpdated").isNull()); assertEquals("synthetic",d.get("provenance").get("license").asText());
   assertEquals((byte)0xef,c.getDatasetCsv("test.one")[0]);
   for(String id : new String[]{"", "a/b", "abc\n", "đxx"}) assertThrows(IllegalArgumentException.class,()->c.getDataset(id));
   assertThrows(java.io.IOException.class,()->c.getDataset("missing"));
  } finally {server.stop(0);}
 }
}
