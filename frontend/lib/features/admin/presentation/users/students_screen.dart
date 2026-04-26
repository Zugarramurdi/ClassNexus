import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/widgets/nexus_data_table.dart';
import 'package:frontend/features/admin/providers/admin_users_provider.dart';
import 'package:frontend/features/admin/presentation/users/user_form_page.dart';
import 'package:go_router/go_router.dart';

class StudentsScreen extends ConsumerWidget {
  const StudentsScreen({super.key});

  void _confirmDelete(BuildContext context, WidgetRef ref, String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar borrado'),
        content: Text('¿Estás seguro de que quieres eliminar al alumno $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(adminUsersProvider.notifier).deleteUser(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Alumno $name eliminado')),
                );
              }
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

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
              'id': u.id,
              'original': u,
            }).toList(),
            searchable: true,
            actionsBuilder: (row) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => UserFormPage(roleId: 3, user: row['original']))
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context, ref, row['id'], row['NOMBRE']),
                ),
              ],
            ),
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
