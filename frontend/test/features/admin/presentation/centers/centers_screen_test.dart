import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/admin/presentation/centers/centers_screen.dart';
import 'package:frontend/features/admin/providers/centers_provider.dart';

class MockCentersNotifier extends CentersNotifier {
  final List<CenterModel> _mockData;
  MockCentersNotifier(this._mockData);

  @override
  Future<List<CenterModel>> build() async => _mockData;
}

void main() {
  testWidgets('CentersScreen shows empty state', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          centersProvider.overrideWith(() => MockCentersNotifier([])),
        ],
        child: const MaterialApp(home: CentersScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No hay centros registrados'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
