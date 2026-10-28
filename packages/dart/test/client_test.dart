import 'dart:io';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:bop_data_sdk_local/bop_data.dart';

void main() {
  test('contract and errors', () async {
    final catalog =
        File('../../tests/fixtures/catalog.json').readAsStringSync();
    final dataset =
        File('../../tests/fixtures/dataset.json').readAsStringSync();
    final transport = MockClient((req) async {
      final p = req.url.path;
      if (p.contains('missing')) return http.Response('', 404);
      if (p.contains('invalid')) return http.Response('{', 200);
      if (p.contains('wrong')) return http.Response('{"spec":"wrong"}', 200);
      if (p.endsWith('.csv'))
        return http.Response.bytes([0xef, 0xbb, 0xbf, 97], 200);
      return http.Response(p.endsWith('datasets.json') ? catalog : dataset, 200,
          headers: {'content-type': 'application/json; charset=utf-8'});
    });
    final c = BopDataClient(client: transport);
    expect((await c.listDatasets())['total'], 2);
    final d = await c.getDataset('test.one');
    expect(d['future'], 'preserved');
    expect(d['freshness']['lastUpdated'], isNull);
    expect(d['provenance']['license'], 'synthetic');
    expect(
        (await c.getDatasetCsv('test.one')).sublist(0, 3), [0xef, 0xbb, 0xbf]);
    for (final id in [
      '',
      'a/b',
      'abc\n',
      'đxx',
      'missing',
      'invalid',
      'wrong'
    ]) {
      await expectLater(
          () async => c.getDataset(id), throwsA(isA<BopDataException>()));
    }
    c.close();
    transport.close();
  });
}
