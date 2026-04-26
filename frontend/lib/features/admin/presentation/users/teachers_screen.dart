import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/widgets/nexus_data_table.dart';
import 'package:frontend/features/admin/providers/admin_users_provider.dart';
import 'package:go_router/go_router.dart';

class TeachersScreen extends ConsumerWidget {
  const TeachersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GESTIÓN DE PROFESORES'),
      ),
      body: usersAsync.when(
        data: (users) {
          final teachers = users.where((u) => u.roleId == 2).toList();
          if (teachers.isEmpty) {
            return const Center(child: Text('No hay profesores registrados'));
          }
          return NexusDataTable(
            columns: const ['NOMBRE', 'APELLIDOS', 'EMAIL'],
            data: teachers.map((u) => {
              'NOMBRE': u.firstName,
              'APELLIDOS': u.lastName,
              'EMAIL': u.email ?? '-',
            }).toList(),
            searchable: true,
            onTap: (row) {
              // Navegar a detalle de profesor
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/users/new?role=2'),
        label: const Text('NUEVO PROFESOR'),
        icon: const Icon(Icons.person_add),
      ),
    );
  }
}
