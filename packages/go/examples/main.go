package main

import (
	"context"
	"encoding/json"
	"fmt"
	bopdata "github.com/masterkimvn/bopdatasdk/packages/go"
	"log"
)

func main() {
	c := bopdata.NewClient()
	ctx := context.Background()
	cat, err := c.ListDatasets(ctx)
	if err != nil {
		log.Fatal(err)
	}
	var entries []struct {
		CanonicalID string `json:"canonicalId"`
	}
	if err = json.Unmarshal(cat["datasets"], &entries); err != nil || len(entries) == 0 {
		log.Fatal("empty or invalid catalog")
	}
	d, err := c.GetDataset(ctx, entries[0].CanonicalID)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(string(d["freshness"]), string(d["provenance"]))
}
