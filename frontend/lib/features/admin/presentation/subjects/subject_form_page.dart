import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/admin/providers/admin_subjects_provider.dart';
import 'package:frontend/features/admin/providers/centers_provider.dart';
import 'package:frontend/features/subjects/providers/subjects_provider.dart';

class SubjectFormPage extends ConsumerStatefulWidget {
  final SubjectData? subject;

  const SubjectFormPage({super.key, this.subject});

  @override
  ConsumerState<SubjectFormPage> createState() => _SubjectFormPageState();
}

class _SubjectFormPageState extends ConsumerState<SubjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  int? _selectedCenterId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject?.name);
    _descriptionController = TextEditingController(text: widget.subject?.description);
    _selectedCenterId = widget.subject?.centerId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.subject != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'EDITAR ASIGNATURA' : 'NUEVA ASIGNATURA'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
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
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la Asignatura',
                        prefixIcon: Icon(Icons.book),
                      ),
                      validator: (v) => v!.isEmpty ? 'Por favor, introduce el nombre' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (Opcional)',
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _CenterDropdown(
                      selectedId: _selectedCenterId,
                      onChanged: (id) => setState(() => _selectedCenterId = id),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading 
                        ? const CircularProgressIndicator() 
                        : Text(_isEditing ? 'GUARDAR CAMBIOS' : 'CREAR ASIGNATURA'),
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
          await ref.read(adminSubjectsProvider.notifier).updateSubject(
            id: widget.subject!.id,
            name: _nameController.text,
            description: _descriptionController.text,
          );
        } else {
          if (_selectedCenterId == null) {
            throw Exception('Debes seleccionar un centro');
          }
          await ref.read(adminSubjectsProvider.notifier).createSubject(
            name: _nameController.text,
            centerId: _selectedCenterId!,
            description: _descriptionController.text,
          );
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar: $e')),
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
