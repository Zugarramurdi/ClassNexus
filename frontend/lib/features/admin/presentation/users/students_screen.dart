import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/widgets/nexus_data_table.dart';
import 'package:frontend/features/admin/providers/admin_users_provider.dart';
import 'package:go_router/go_router.dart';

class StudentsScreen extends ConsumerWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GESTIÓN DE ALUMNOS'),
      ),
      body: usersAsync.when(
        data: (users) {
          final students = users.where((u) => u.roleId == 3).toList();
          if (students.isEmpty) {
            return const Center(child: Text('No hay alumnos registrados'));
          }
          return NexusDataTable(
            columns: const ['NOMBRE', 'APELLIDOS', 'EMAIL'],
            data: students.map((u) => {
              'NOMBRE': u.firstName,
              'APELLIDOS': u.lastName,
              'EMAIL': u.email ?? '-',
            }).toList(),
            searchable: true,
            onTap: (row) {
              // Navegar a detalle de alumno
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/users/new?role=3'),
        label: const Text('MATRICULAR ALUMNO'),
        icon: const Icon(Icons.school),
      ),
    );
  }
}
