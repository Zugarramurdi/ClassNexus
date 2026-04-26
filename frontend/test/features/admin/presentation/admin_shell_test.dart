import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin/presentation/admin_shell.dart';

void main() {
  testWidgets('AdminShell shows sidebar on desktop', (WidgetTester tester) async {
    // Simular ancho de escritorio
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(MaterialApp(
      home: AdminShell(
        child: Container(),
      ),
    ));

    expect(find.byIcon(Icons.business), findsOneWidget); // Icono de Centros
    expect(find.text('CENTROS'), findsOneWidget);
  });

  testWidgets('AdminShell shows bottom navigation on mobile', (WidgetTester tester) async {
    // Simular ancho de móvil
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(MaterialApp(
      home: AdminShell(
        child: Container(),
      ),
    ));

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('CENTROS'), findsOneWidget);
  });
}
