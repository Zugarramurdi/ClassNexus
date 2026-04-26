import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/admin/providers/centers_provider.dart';
import 'package:go_router/go_router.dart';

class CenterFormPage extends ConsumerStatefulWidget {
  final CenterModel? center;
  const CenterFormPage({super.key, this.center});

  @override
  ConsumerState<CenterFormPage> createState() => _CenterFormPageState();
}

class _CenterFormPageState extends ConsumerState<CenterFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _addressController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.center?.name);
    _codeController = TextEditingController(text: widget.center?.code);
    _addressController = TextEditingController(text: widget.center?.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.center != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'EDITAR CENTRO' : 'NUEVO CENTRO'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Centro',
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (v) => v!.isEmpty ? 'Por favor, introduce el nombre' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Código',
                        hintText: 'Ej: CE-001',
                        prefixIcon: Icon(Icons.tag),
                      ),
                      validator: (v) => v!.isEmpty ? 'Por favor, introduce el código' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección (Opcional)',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : Text(_isEditing ? 'GUARDAR CAMBIOS' : 'CREAR CENTRO', style: const TextStyle(fontWeight: FontWeight.bold)),
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
          await ref.read(centersProvider.notifier).updateCenter(
            id: widget.center!.id,
            name: _nameController.text,
            code: _codeController.text,
            address: _addressController.text.isEmpty ? null : _addressController.text,
          );
        } else {
          await ref.read(centersProvider.notifier).createCenter(
            name: _nameController.text,
            code: _codeController.text,
            address: _addressController.text.isEmpty ? null : _addressController.text,
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
