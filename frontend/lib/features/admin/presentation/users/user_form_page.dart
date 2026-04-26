import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/admin/providers/admin_users_provider.dart';
import 'package:frontend/features/admin/providers/centers_provider.dart';
import 'package:go_router/go_router.dart';

class UserFormPage extends ConsumerStatefulWidget {
  final int roleId;
  const UserFormPage({super.key, required this.roleId});

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
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: LinearProgressIndicator(),
      ),
      error: (_, __) => const Text('Error al cargar centros'),
    );
  }
}

class _UserFormPageState extends ConsumerState<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  int? _selectedCenterId;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  String get _roleName => widget.roleId == 2 ? 'PROFESOR' : 'ALUMNO';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NUEVO $_roleName'),
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
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email / Usuario',
                        prefixIcon: Icon(Icons.alternate_email),
                        hintText: 'ejemplo@correo.com',
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
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator() 
                        : Text('CREAR $_roleName', style: const TextStyle(fontWeight: FontWeight.bold)),
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
        await ref.read(adminUsersProvider.notifier).createUser(
          email: _emailController.text,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          roleId: widget.roleId,
          centerId: _selectedCenterId,
        );
        if (mounted) context.pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear $_roleName: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}
