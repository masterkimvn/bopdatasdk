import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class BopDataException implements Exception {
  final String kind;
  final int? status;
  BopDataException(this.kind, [this.status]);
  @override
  String toString() => status == null
      ? 'BopDataException: $kind'
      : 'BopDataException: HTTP $status';
}

class BopDataClient {
  final String baseUrl;
  final Duration timeout;
  final http.Client _client;
  final bool _ownsClient;
  static const int maxBytes = 8000000;
  BopDataClient(
      {String baseUrl = 'https://data.bop.ink',
      this.timeout = const Duration(seconds: 10),
      http.Client? client})
      : baseUrl = _validateBase(baseUrl),
        _client = client ?? http.Client(),
        _ownsClient = client == null {
    if (timeout <= Duration.zero) throw ArgumentError('Invalid timeout');
  }
  static String _validateBase(String base) {
    final uri = Uri.tryParse(base);
    if (uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) throw ArgumentError('Invalid base URL');
    return base.replaceFirst(RegExp(r'/+$'), '');
  }

  String _id(String id) {
    if (!RegExp(r'^[A-Za-z0-9._-]{3,}$').hasMatch(id) ||
        id.contains('\n') ||
        id.contains('\r')) throw BopDataException('invalid_id');
    return Uri.encodeComponent(id);
  }

  Future<Uint8List> _request(String path) async {
    try {
      final request = http.Request('GET', Uri.parse(baseUrl + path))
        ..followRedirects = false;
      final response = await _client.send(request).timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300)
        throw BopDataException('http', response.statusCode);
      if ((response.contentLength ?? 0) > maxBytes)
        throw BopDataException('too_large');
      final builder = BytesBuilder(copy: false);
      await for (final chunk in response.stream.timeout(timeout)) {
        if (builder.length + chunk.length > maxBytes)
          throw BopDataException('too_large');
        builder.add(chunk);
      }
      return builder.takeBytes();
    } on TimeoutException {
      throw BopDataException('timeout');
    } on http.ClientException {
      throw BopDataException('transport');
    }
  }

  Future<Map<String, dynamic>> _json(String path, String spec) async {
    final bytes = await _request(path);
    dynamic result;
    try {
      result = jsonDecode(utf8.decode(bytes));
    } on FormatException {
      throw BopDataException('json');
    }
    if (result is! Map<String, dynamic> || result['spec'] != spec)
      throw BopDataException('spec');
    return result;
  }

  Future<Map<String, dynamic>> listDatasets() =>
      _json('/api/v1/datasets.json', 'bop.catalog/1');
  Future<Map<String, dynamic>> getDataset(String id) =>
      _json('/api/v1/datasets/${_id(id)}.json', 'bop.dataset/1');
  Future<Uint8List> getDatasetCsv(String id) =>
      _request('/api/v1/datasets/${_id(id)}.csv');
  void close() {
    if (_ownsClient) _client.close();
  }
}
