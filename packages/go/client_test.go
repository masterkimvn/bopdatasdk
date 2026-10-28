package bopdata

import (
	"context"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
)

func TestContract(t *testing.T) {
	s := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/api/v1/datasets.json" {
			b, _ := os.ReadFile("../../tests/fixtures/catalog.json")
			w.Write(b)
			return
		}
		if r.URL.Path == "/api/v1/datasets/test.one.csv" {
			w.Write([]byte("\xef\xbb\xbfa,b\r\n"))
			return
		}
		if r.URL.Path == "/api/v1/datasets/missing.json" {
			w.WriteHeader(404)
			return
		}
		b, _ := os.ReadFile("../../tests/fixtures/dataset.json")
		w.Write(b)
	}))
	defer s.Close()
	c := NewClient()
	c.BaseURL = s.URL
	ctx := context.Background()
	if _, e := c.ListDatasets(ctx); e != nil {
		t.Fatal(e)
	}
	d, e := c.GetDataset(ctx, "test.one")
	if e != nil || string(d["future"]) != `"preserved"` {
		t.Fatal(e)
	}
	if _, e = c.GetDatasetCSV(ctx, "test.one"); e != nil {
		t.Fatal(e)
	}
	for _, id := range []string{"", "a/b", "https://x", "đxx", "missing"} {
		if _, e = c.GetDataset(ctx, id); e == nil {
			t.Fatal(id)
		}
	}
}

func TestErrorsAndCancellation(t *testing.T) {
	s := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/api/v1/datasets/status429.json":
			w.WriteHeader(429)
		case "/api/v1/datasets/status503.json":
			w.WriteHeader(503)
		case "/api/v1/datasets/invalid.json":
			w.Write([]byte("{"))
		case "/api/v1/datasets/wrong.json":
			w.Write([]byte(`{"spec":"wrong"}`))
		case "/api/v1/datasets/redirect.json":
			http.Redirect(w, r, "https://example.com", http.StatusFound)
		default:
			<-r.Context().Done()
		}
	}))
	defer s.Close()
	c := NewClient()
	c.BaseURL = s.URL
	for _, id := range []string{"status429", "status503", "invalid", "wrong", "redirect"} {
		if _, err := c.GetDataset(context.Background(), id); err == nil {
			t.Fatalf("accepted %s", id)
		}
	}
	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	if _, err := c.GetDataset(ctx, "slow"); err == nil {
		t.Fatal("cancellation accepted")
	}
}
