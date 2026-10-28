import ink.bop.data.Client;
public class Main {
    public static void main(String[] args) throws Exception {
        Client client = new Client();
        var catalog = client.listDatasets();
        var dataset = client.getDataset(catalog.get("datasets").get(0).get("canonicalId").asText());
        System.out.println(dataset.get("freshness"));
        System.out.println(dataset.get("provenance"));
    }
}
