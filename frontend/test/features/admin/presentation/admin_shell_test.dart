import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin/presentation/admin_shell.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('AdminShell shows sidebar on desktop', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/admin/centers',
      routes: [
        ShellRoute(
          builder: (context, state, child) => AdminShell(child: child),
          routes: [
            GoRoute(path: '/admin/centers', builder: (context, state) => Container()),
          ],
        ),
      ],
    );

    // Simular ancho de escritorio
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.business), findsAtLeastNWidgets(1));
    expect(find.text('CENTROS'), findsAtLeastNWidgets(1));
  });

  testWidgets('AdminShell shows bottom navigation on mobile', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/admin/centers',
      routes: [
        ShellRoute(
          builder: (context, state, child) => AdminShell(child: child),
          routes: [
            GoRoute(path: '/admin/centers', builder: (context, state) => Container()),
          ],
        ),
      ],
    );

    // Simular ancho de móvil
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('CENTROS'), findsAtLeastNWidgets(1));
  });
}
