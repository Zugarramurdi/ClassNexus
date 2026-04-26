import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/widgets/nexus_data_table.dart';
import 'package:frontend/features/admin/providers/centers_provider.dart';
import 'package:go_router/go_router.dart';

class CentersScreen extends ConsumerWidget {
  const CentersScreen({super.key});

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
            data: centers.map((c) => c.toTableData()).toList(),
            searchable: true,
            onTap: (row) {
              // TODO: Navegar a detalle/edición
            },
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
