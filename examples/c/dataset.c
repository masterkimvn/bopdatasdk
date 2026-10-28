#include <curl/curl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Writes JSON or CSV to stdout. Supply an ASCII canonical ID and format. */
int main(int argc, char **argv) {
    if (argc != 3 || strlen(argv[1]) < 3 || strspn(argv[1], "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._-") != strlen(argv[1]) || (strcmp(argv[2], "json") && strcmp(argv[2], "csv"))) {
        fprintf(stderr, "Usage: %s canonical-id json|csv\n", argv[0]); return 2;
    }
    const char *prefix = "https://data.bop.ink/api/v1/datasets/";
    size_t n = strlen(prefix) + strlen(argv[1]) + strlen(argv[2]) + 2;
    char *url = malloc(n);
    if (!url) return 1;
    snprintf(url, n, "%s%s.%s", prefix, argv[1], argv[2]);
    CURL *c = curl_easy_init();
    if (!c) { free(url); return 1; }
    curl_easy_setopt(c, CURLOPT_URL, url);
    curl_easy_setopt(c, CURLOPT_TIMEOUT, 10L);
    curl_easy_setopt(c, CURLOPT_FAILONERROR, 1L);
    CURLcode status = curl_easy_perform(c);
    if (status != CURLE_OK) fprintf(stderr, "Request failed: %s\n", curl_easy_strerror(status));
    curl_easy_cleanup(c); free(url);
    return status == CURLE_OK ? 0 : 1;
}
