import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/admin/providers/admin_users_provider.dart';
import 'package:frontend/features/admin/providers/centers_provider.dart';
import 'package:frontend/features/profile/providers/profile_provider.dart';
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

class _UserFormPageState extends ConsumerState<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  int? _selectedCenterId;
  String? _selectedTutorId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user?.email);
    _firstNameController = TextEditingController(text: widget.user?.firstName);
    _lastNameController = TextEditingController(text: widget.user?.lastName);
    _selectedCenterId = widget.user?.centerId;
    _selectedTutorId = widget.user?.tutorId;
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
                      onChanged: (id) => setState(() => _selectedCenterId = id),
                    ),
                    if (widget.roleId == 3) ...[
                      const SizedBox(height: 16),
                      _TutorDropdown(
                        selectedId: _selectedTutorId,
                        onChanged: (id) => setState(() => _selectedTutorId = id),
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
            tutorId: _selectedTutorId,
          );
        } else {
          await ref.read(adminUsersProvider.notifier).createUser(
            email: _emailController.text,
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            roleId: widget.roleId,
            centerId: _selectedCenterId,
            tutorId: _selectedTutorId,
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
