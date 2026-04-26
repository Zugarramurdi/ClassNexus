import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/admin/presentation/users/user_form_page.dart';

void main() {
  testWidgets('UserFormPage shows user fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: UserFormPage(roleId: 2), // 2 = Teacher
        ),
      ),
    );

    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Apellidos'), findsOneWidget);
    expect(find.text('Email / Usuario'), findsOneWidget);
    expect(find.text('CREAR PROFESOR'), findsOneWidget);
  });
}
