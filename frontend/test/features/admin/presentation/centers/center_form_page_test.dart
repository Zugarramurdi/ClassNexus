import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/admin/presentation/centers/center_form_page.dart';

void main() {
  testWidgets('CenterFormPage shows form fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: CenterFormPage()),
      ),
    );

    expect(find.text('Nombre del Centro'), findsOneWidget);
    expect(find.text('Código'), findsOneWidget);
    expect(find.text('Dirección (Opcional)'), findsOneWidget);
    expect(find.text('GUARDAR CENTRO'), findsOneWidget);
  });
}
