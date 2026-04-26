import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/widgets/nexus_data_table.dart';
import 'package:frontend/features/admin/providers/admin_subjects_provider.dart';
import 'package:frontend/features/subjects/providers/subjects_provider.dart';
import 'subject_form_page.dart';

class AdminSubjectsListPage extends ConsumerWidget {
  const AdminSubjectsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(adminSubjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GESTIÓN DE ASIGNATURAS'),
      ),
      body: subjectsAsync.when(
        data: (subjects) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: NexusDataTable<SubjectData>(
            items: subjects,
            searchPlaceholder: 'Buscar asignatura...',
            searchMatcher: (subject, query) => 
                subject.name.toLowerCase().contains(query.toLowerCase()),
            columns: [
              NexusColumn(
                label: 'NOMBRE',
                builder: (s) => Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              NexusColumn(
                label: 'DESCRIPCIÓN',
                builder: (s) => Text(s.description ?? '-', style: const TextStyle(fontSize: 13)),
              ),
              NexusColumn(
                label: 'CENTRO',
                builder: (s) => Text(s.center?['name'] ?? 'N/A'),
              ),
            ],
            actionsBuilder: (subject) => [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SubjectFormPage(subject: subject)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context, ref, subject),
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
          MaterialPageRoute(builder: (_) => const SubjectFormPage()),
        ),
        label: const Text('NUEVA ASIGNATURA'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, SubjectData subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Asignatura'),
        content: Text('¿Estás seguro de que quieres eliminar "${subject.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(adminSubjectsProvider.notifier).deleteSubject(subject.id);
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
