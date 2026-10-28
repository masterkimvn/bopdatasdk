import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bop_data_demo/main.dart';

void main() {
  testWidgets('shows returned dataset and provenance', (tester) async {
    await tester.pumpWidget(
      BopDataApp(
        loader: () async => {
          'canonicalId': 'test.one',
          'data': {'value': 42},
          'freshness': {'lastUpdated': '2026-01-01'},
          'provenance': {'publisher': 'Example'},
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('test.one'), findsOneWidget);
    expect(find.textContaining('42'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('Example'), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('Example'), findsOneWidget);
  });
  testWidgets('shows connection errors', (tester) async {
    await tester.pumpWidget(
      BopDataApp(loader: () async => throw Exception('offline')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Unable to load the dataset.'), findsOneWidget);
  });
}
