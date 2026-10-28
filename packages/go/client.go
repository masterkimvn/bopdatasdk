// Package bopdata provides read-only access to BOP Data.
package bopdata

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"regexp"
	"strings"
	"time"
)

type Client struct {
	BaseURL    string
	HTTPClient *http.Client
}

func NewClient() *Client {
	return &Client{BaseURL: "https://data.bop.ink", HTTPClient: &http.Client{Timeout: 10 * time.Second}}
}

var validID = regexp.MustCompile(`^[A-Za-z0-9._-]{3,}$`)

func (c *Client) request(ctx context.Context, path, spec string) ([]byte, error) {
	u, err := url.Parse(c.BaseURL)
	if err != nil || (u.Scheme != "http" && u.Scheme != "https") || u.Host == "" || u.User != nil || u.RawQuery != "" || u.Fragment != "" {
		return nil, fmt.Errorf("invalid base URL")
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, strings.TrimRight(c.BaseURL, "/")+path, nil)
	if err != nil {
		return nil, fmt.Errorf("invalid request")
	}
	client := c.HTTPClient
	if client == nil {
		client = &http.Client{Timeout: 10 * time.Second}
	}
	safeClient := *client
	safeClient.CheckRedirect = func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse }
	client = &safeClient
	resp, err := client.Do(req)
	if err != nil {
		if ctx.Err() != nil {
			return nil, ctx.Err()
		}
		return nil, fmt.Errorf("request failed")
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, fmt.Errorf("HTTP %d", resp.StatusCode)
	}
	b, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("reading response: %w", err)
	}
	if spec != "" {
		var v map[string]json.RawMessage
		if json.Unmarshal(b, &v) != nil {
			return nil, fmt.Errorf("invalid JSON response")
		}
		var got string
		if json.Unmarshal(v["spec"], &got) != nil || got != spec {
			return nil, fmt.Errorf("incompatible response spec")
		}
	}
	return b, nil
}
func (c *Client) ListDatasets(ctx context.Context) (map[string]json.RawMessage, error) {
	b, e := c.request(ctx, "/api/v1/datasets.json", "bop.catalog/1")
	if e != nil {
		return nil, e
	}
	var v map[string]json.RawMessage
	e = json.Unmarshal(b, &v)
	return v, e
}
func (c *Client) GetDataset(ctx context.Context, id string) (map[string]json.RawMessage, error) {
	if !validID.MatchString(id) {
		return nil, fmt.Errorf("invalid canonical ID")
	}
	b, e := c.request(ctx, "/api/v1/datasets/"+url.PathEscape(id)+".json", "bop.dataset/1")
	if e != nil {
		return nil, e
	}
	var v map[string]json.RawMessage
	e = json.Unmarshal(b, &v)
	return v, e
}
func (c *Client) GetDatasetCSV(ctx context.Context, id string) ([]byte, error) {
	if !validID.MatchString(id) {
		return nil, fmt.Errorf("invalid canonical ID")
	}
	return c.request(ctx, "/api/v1/datasets/"+url.PathEscape(id)+".csv", "")
}
