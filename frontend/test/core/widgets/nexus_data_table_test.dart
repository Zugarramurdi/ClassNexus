import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/widgets/nexus_data_table.dart';

void main() {
  testWidgets('NexusDataTable displays headers and data', (WidgetTester tester) async {
    final columns = ['Name', 'Role'];
    final data = [
      {'Name': 'John Doe', 'Role': 'Admin'},
      {'Name': 'Jane Smith', 'Role': 'Teacher'},
    ];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NexusDataTable(
          columns: columns,
          data: data,
        ),
      ),
    ));

    expect(find.text('NAME'), findsNWidgets(2));
    expect(find.text('ROLE'), findsNWidgets(2));
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Jane Smith'), findsOneWidget);
  });

  testWidgets('NexusDataTable filters data based on search', (WidgetTester tester) async {
    final columns = ['Name'];
    final data = [
      {'Name': 'Apple'},
      {'Name': 'Banana'},
    ];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NexusDataTable(
          columns: columns,
          data: data,
          searchable: true,
        ),
      ),
    ));

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);

    // Entrar texto en el buscador
    await tester.enterText(find.byType(TextField), 'App');
    await tester.pump();

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Banana'), findsNothing);
  });
}
