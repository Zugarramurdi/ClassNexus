import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/admin/providers/cycles_provider.dart';
import 'package:frontend/features/admin/providers/centers_provider.dart';
import 'package:frontend/features/admin/providers/admin_subjects_provider.dart';
import 'package:frontend/features/subjects/providers/subjects_provider.dart';

class CycleFormPage extends ConsumerStatefulWidget {
  final CycleData? cycle;

  const CycleFormPage({super.key, this.cycle});

  @override
  ConsumerState<CycleFormPage> createState() => _CycleFormPageState();
}

class _CycleFormPageState extends ConsumerState<CycleFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  int? _selectedCenterId;
  List<int> _selectedSubjectIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.cycle?.name);
    _descriptionController = TextEditingController(text: widget.cycle?.description);
    _selectedCenterId = widget.cycle?.centerId;
    _selectedSubjectIds = widget.cycle?.subjectIds ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.cycle != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'EDITAR CICLO' : 'NUEVO CICLO'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.all(24.0),
          child: Card(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Ciclo (ej. DAM, DAW)',
                        prefixIcon: Icon(Icons.school),
                      ),
                      validator: (v) => v!.isEmpty ? 'Por favor, introduce el nombre' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Descripción Completa',
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _CenterDropdown(
                      selectedId: _selectedCenterId,
                      onChanged: (id) {
                        setState(() {
                          if (_selectedCenterId != id) {
                            _selectedSubjectIds = [];
                          }
                          _selectedCenterId = id;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    _SubjectSelector(
                      centerId: _selectedCenterId,
                      selectedIds: _selectedSubjectIds,
                      onChanged: (ids) => setState(() => _selectedSubjectIds = ids),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading 
                        ? const CircularProgressIndicator() 
                        : Text(_isEditing ? 'GUARDAR CAMBIOS' : 'CREAR CICLO'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        if (_isEditing) {
          await ref.read(cyclesProvider.notifier).updateCycle(
            id: widget.cycle!.id,
            name: _nameController.text,
            description: _descriptionController.text,
            subjectIds: _selectedSubjectIds,
          );
        } else {
          if (_selectedCenterId == null) throw Exception('Selecciona un centro');
          await ref.read(cyclesProvider.notifier).createCycle(
            name: _nameController.text,
            centerId: _selectedCenterId!,
            description: _descriptionController.text,
            subjectIds: _selectedSubjectIds,
          );
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}

class _CenterDropdown extends ConsumerWidget {
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  const _CenterDropdown({required this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final centersAsync = ref.watch(centersProvider);
    return centersAsync.when(
      data: (centers) => DropdownButtonFormField<int>(
        value: selectedId,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Centro',
          prefixIcon: Icon(Icons.business),
        ),
        items: centers.map((c) => DropdownMenuItem(
          value: c.id, 
          child: Text(
            c.name,
            overflow: TextOverflow.ellipsis,
          )
        )).toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Por favor, selecciona un centro' : null,
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error al cargar centros'),
    );
  }
}

class _SubjectSelector extends ConsumerWidget {
  final int? centerId;
  final List<int> selectedIds;
  final ValueChanged<List<int>> onChanged;

  const _SubjectSelector({
    required this.centerId,
    required this.selectedIds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (centerId == null) return const SizedBox.shrink();

    final subjectsAsync = ref.watch(adminSubjectsProvider);

    return subjectsAsync.when(
      data: (subjects) {
        final centerSubjects = subjects.where((s) => s.centerId == centerId).toList();

        if (centerSubjects.isEmpty) {
          return const Text('No hay asignaturas en este centro', style: TextStyle(fontStyle: FontStyle.italic));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Asignaturas del Ciclo', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: centerSubjects.map((s) {
                final isSelected = selectedIds.contains(s.id);
                return FilterChip(
                  label: Text(s.name, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : null)),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newList = List<int>.from(selectedIds);
                    if (selected) {
                      newList.add(s.id);
                    } else {
                      newList.remove(s.id);
                    }
                    onChanged(newList);
                  },
                  selectedColor: Theme.of(context).colorScheme.primary,
                  checkmarkColor: Colors.white,
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error al cargar asignaturas'),
    );
  }
}
