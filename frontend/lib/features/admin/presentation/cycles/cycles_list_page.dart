import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/widgets/nexus_data_table.dart';
import 'package:frontend/features/admin/providers/cycles_provider.dart';
import 'cycle_form_page.dart';

class AdminCyclesListPage extends ConsumerWidget {
  const AdminCyclesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cyclesAsync = ref.watch(cyclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GESTIÓN DE CICLOS FORMATIVOS'),
      ),
      body: cyclesAsync.when(
        data: (cycles) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: NexusDataTable<CycleData>(
            items: cycles,
            searchPlaceholder: 'Buscar ciclo...',
            searchMatcher: (cycle, query) => 
                cycle.name.toLowerCase().contains(query.toLowerCase()),
            columns: [
              NexusColumn(
                label: 'CICLO',
                builder: (c) => Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              NexusColumn(
                label: 'DESCRIPCIÓN',
                builder: (c) => Text(c.description ?? '-', style: const TextStyle(fontSize: 13)),
              ),
              NexusColumn(
                label: 'ASIGNATURAS',
                builder: (c) => Text('${c.subjectIds?.length ?? 0} asignaturas'),
              ),
            ],
            actionsBuilder: (cycle) => [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CycleFormPage(cycle: cycle)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context, ref, cycle),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CycleFormPage()),
        ),
        label: const Text('NUEVO CICLO'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, CycleData cycle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Ciclo'),
        content: Text('¿Estás seguro de que quieres eliminar "${cycle.name}"? Se desvincularán todas las asignaturas asociadas.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(cyclesProvider.notifier).deleteCycle(cycle.id);
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
