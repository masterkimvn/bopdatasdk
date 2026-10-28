#include <curl/curl.h>
#include <iostream>
#include <regex>
#include <string>
int main(int argc, char **argv) {
    if (argc != 3 || !std::regex_match(argv[1], std::regex("[A-Za-z0-9._-]{3,}")) || (std::string(argv[2]) != "json" && std::string(argv[2]) != "csv")) {
        std::cerr << "Usage: " << argv[0] << " canonical-id json|csv\n"; return 2;
    }
    std::string url = std::string("https://data.bop.ink/api/v1/datasets/") + argv[1] + "." + argv[2];
    CURL *c = curl_easy_init(); if (!c) return 1;
    curl_easy_setopt(c, CURLOPT_URL, url.c_str());
    curl_easy_setopt(c, CURLOPT_TIMEOUT, 10L);
    curl_easy_setopt(c, CURLOPT_FAILONERROR, 1L);
    CURLcode status = curl_easy_perform(c);
    if (status != CURLE_OK) std::cerr << "Request failed: " << curl_easy_strerror(status) << '\n';
    curl_easy_cleanup(c); return status == CURLE_OK ? 0 : 1;
}
