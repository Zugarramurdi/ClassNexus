import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/widgets/nexus_data_table.dart';
import 'package:frontend/features/admin/providers/centers_provider.dart';
import 'package:frontend/features/admin/presentation/centers/center_form_page.dart';
import 'package:go_router/go_router.dart';

class CentersScreen extends ConsumerWidget {
  const CentersScreen({super.key});

  void _confirmDelete(BuildContext context, WidgetRef ref, int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar borrado'),
        content: Text('¿Estás seguro de que quieres eliminar el centro $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(centersProvider.notifier).deleteCenter(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Centro $name eliminado')),
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
    final centersAsync = ref.watch(centersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GESTIÓN DE CENTROS',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: centersAsync.when(
        data: (centers) {
          if (centers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay centros registrados',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }
          return NexusDataTable(
            columns: const ['NOMBRE', 'CÓDIGO', 'DIRECCIÓN'],
            data: centers.map((c) => {
              ...c.toTableData(),
              'original': c,
            }).toList(),
            searchable: true,
            actionsBuilder: (row) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CenterFormPage(center: row['original']))
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context, ref, row['id'] as int, row['NOMBRE']),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error al cargar centros: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/centers/new'),
        label: const Text('NUEVO CENTRO'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
