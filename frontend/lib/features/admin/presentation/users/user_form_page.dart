import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/admin/providers/admin_users_provider.dart';
import 'package:frontend/features/admin/providers/centers_provider.dart';
import 'package:frontend/features/admin/providers/cycles_provider.dart';
import 'package:frontend/features/profile/providers/profile_provider.dart';
import 'package:frontend/features/subjects/providers/subjects_provider.dart';
import 'package:go_router/go_router.dart';

class UserFormPage extends ConsumerStatefulWidget {
  final int roleId;
  final ProfileData? user;

  const UserFormPage({super.key, required this.roleId, this.user});

  @override
  ConsumerState<UserFormPage> createState() => _UserFormPageState();
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
        decoration: const InputDecoration(
          labelText: 'Centro',
          prefixIcon: Icon(Icons.business),
        ),
        items: centers.map((c) => DropdownMenuItem(
          value: c.id, 
          child: Text(c.name)
        )).toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Por favor, selecciona un centro' : null,
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error al cargar centros'),
    );
  }
}

class _TutorDropdown extends ConsumerWidget {
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const _TutorDropdown({required this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);
    
    return usersAsync.when(
      data: (users) {
        // Solo profesores (role_id == 2) pueden ser tutores
        final teachers = users.where((u) => u.roleId == 2).toList();
        
        return DropdownButtonFormField<String>(
          value: selectedId,
          decoration: const InputDecoration(
            labelText: 'Tutor asignado',
            prefixIcon: Icon(Icons.school),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Sin tutor asignado'),
            ),
            ...teachers.map((t) => DropdownMenuItem(
              value: t.id, 
              child: Text('${t.firstName} ${t.lastName}')
            )),
          ],
          onChanged: onChanged,
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error al cargar profesores'),
    );
  }
}

class _CycleDropdown extends ConsumerWidget {
  final int? centerId;
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  const _CycleDropdown({required this.centerId, required this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (centerId == null) return const SizedBox.shrink();
    final cyclesAsync = ref.watch(cyclesProvider);
    
    return cyclesAsync.when(
      data: (cycles) {
        final centerCycles = cycles.where((c) => c.centerId == centerId).toList();
        return DropdownButtonFormField<int>(
          value: selectedId,
          decoration: const InputDecoration(
            labelText: 'Ciclo Formativo',
            prefixIcon: Icon(Icons.history_edu),
          ),
          items: [
            const DropdownMenuItem<int>(value: null, child: Text('Sin ciclo asignado')),
            ...centerCycles.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
          ],
          onChanged: onChanged,
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error al cargar ciclos'),
    );
  }
}

class _UserFormPageState extends ConsumerState<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  int? _selectedCenterId;
  int? _selectedCycleId;
  String? _selectedTutorId;
  List<int> _selectedSubjectIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user?.email);
    _firstNameController = TextEditingController(text: widget.user?.firstName);
    _lastNameController = TextEditingController(text: widget.user?.lastName);
    _selectedCenterId = widget.user?.centerId;
    _selectedCycleId = widget.user?.cycleId;
    _selectedTutorId = widget.user?.tutorId;
    _selectedSubjectIds = widget.user?.teachingSubjects ?? [];
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.user != null;
  String get _roleName => widget.roleId == 2 ? 'PROFESOR' : 'ALUMNO';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'EDITAR $_roleName' : 'NUEVO $_roleName'),
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
                      controller: _emailController,
                      enabled: !_isEditing,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email / Usuario',
                        prefixIcon: const Icon(Icons.alternate_email),
                        hintText: 'ejemplo@correo.com',
                        filled: _isEditing,
                      ),
                      validator: (v) => v!.isEmpty ? 'Por favor, introduce el email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _firstNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => v!.isEmpty ? 'Por favor, introduce el nombre' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Apellidos',
                        prefixIcon: Icon(Icons.people_outline),
                      ),
                      validator: (v) => v!.isEmpty ? 'Por favor, introduce los apellidos' : null,
                    ),
                    const SizedBox(height: 16),
                    _CenterDropdown(
                      selectedId: _selectedCenterId,
                      onChanged: (id) {
                        setState(() {
                          if (_selectedCenterId != id) {
                            _selectedSubjectIds = []; // Limpiar asignaturas si cambia el centro
                          }
                          _selectedCenterId = id;
                        });
                      },
                    ),
                    if (widget.roleId == 3) ...[
                      const SizedBox(height: 16),
                      _TutorDropdown(
                        selectedId: _selectedTutorId,
                        onChanged: (id) => setState(() => _selectedTutorId = id),
                      ),
                      const SizedBox(height: 16),
                      _CycleDropdown(
                        centerId: _selectedCenterId,
                        selectedId: _selectedCycleId,
                        onChanged: (id) {
                          setState(() {
                            _selectedCycleId = id;
                            if (id != null) {
                              // Auto-seleccionar asignaturas del ciclo
                              final cycles = ref.read(cyclesProvider).value;
                              if (cycles != null) {
                                final cycle = cycles.firstWhere((c) => c.id == id);
                                if (cycle.subjectIds != null) {
                                  _selectedSubjectIds = List<int>.from(cycle.subjectIds!);
                                }
                              }
                            }
                          });
                        },
                      ),
                    ],
                    if (widget.roleId == 2 || widget.roleId == 3) ...[
                      const SizedBox(height: 16),
                      _SubjectSelector(
                        centerId: _selectedCenterId,
                        roleId: widget.roleId,
                        selectedIds: _selectedSubjectIds,
                        onChanged: (ids) => setState(() => _selectedSubjectIds = ids),
                      ),
                    ],
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : Text(_isEditing ? 'GUARDAR CAMBIOS' : 'CREAR $_roleName', style: const TextStyle(fontWeight: FontWeight.bold)),
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
          await ref.read(adminUsersProvider.notifier).updateUser(
            id: widget.user!.id,
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            centerId: _selectedCenterId,
            cycleId: _selectedCycleId,
            tutorId: _selectedTutorId,
            subjectIds: _selectedSubjectIds,
          );
        } else {
          await ref.read(adminUsersProvider.notifier).createUser(
            email: _emailController.text,
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            roleId: widget.roleId,
            centerId: _selectedCenterId,
            cycleId: _selectedCycleId,
            tutorId: _selectedTutorId,
            subjectIds: _selectedSubjectIds,
          );
        }
        if (mounted) context.pop();
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

class _SubjectSelector extends ConsumerWidget {
  final int? centerId;
  final int roleId;
  final List<int> selectedIds;
  final ValueChanged<List<int>> onChanged;

  const _SubjectSelector({
    required this.centerId,
    required this.roleId,
    required this.selectedIds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (centerId == null) return const SizedBox.shrink();

    final subjectsAsync = ref.watch(subjectsProvider);

    return subjectsAsync.when(
      data: (subjects) {
        final centerSubjects = subjects.where((s) => s.centerId == centerId).toList();

        if (centerSubjects.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('No hay asignaturas registradas en este centro', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              roleId == 2 ? 'Asignaturas que imparte' : 'Asignaturas matriculadas', 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 0,
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
