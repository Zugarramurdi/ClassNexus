import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/core/utils/messenger.dart';

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final auth = ref.read(authNotifierProvider.notifier);
      final email = ref.read(currentUserProvider)?.email;

      if (email == null) throw Exception('No se encontró el email del usuario');

      final currentPassword = _currentPasswordController.text.trim();
      final newPassword = _passwordController.text.trim();

      // 1. Verificar contraseña actual
      try {
        await ref.read(supabaseClientProvider).auth.signInWithPassword(
          email: email,
          password: currentPassword,
        );
      } catch (e) {
        throw Exception('La contraseña actual es incorrecta');
      }

      // 2. Actualizar contraseña
      await auth.updatePassword(newPassword);

      if (mounted) {
        Navigator.pop(context); // Cierra el diálogo
        
        // Usar el mensajero global para que el mensaje sobreviva aunque la app se refresque
        showGlobalSnackBar('Contraseña actualizada correctamente');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Cambiar Contraseña'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Confirma tu identidad actual antes de establecer una nueva contraseña.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Contraseña Actual',
                  prefixIcon: Icon(Icons.lock_person_outlined),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Nueva Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    focusNode: FocusNode(skipTraversal: true),
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (value.length < 8) return 'Mínimo 8 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'Confirmar Nueva Contraseña',
                  prefixIcon: Icon(Icons.lock_reset),
                ),
                validator: (value) {
                  if (value != _passwordController.text) return 'Las contraseñas no coinciden';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Actualizar'),
        ),
      ],
    );
  }
}
