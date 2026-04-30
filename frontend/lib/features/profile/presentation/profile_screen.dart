import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/widgets/nexus_card.dart';
import 'package:frontend/core/widgets/responsive_layout.dart';
import 'package:frontend/core/widgets/nexus_sidebar.dart';
import 'package:frontend/features/profile/providers/profile_provider.dart';
import 'package:frontend/features/profile/presentation/widgets/change_password_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (profile) {
          if (profile == null) return const Center(child: Text('Perfil no encontrado'));

          return ResponsiveLayout(
            mobile: _ProfileMobile(profile: profile),
            desktop: _ProfileDesktop(profile: profile),
          );
        },
      ),
    );
  }
}

class _ProfileDesktop extends StatelessWidget {
  final ProfileData profile;
  const _ProfileDesktop({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _ProfileContent(profile: profile),
        ),
      ),
    );
  }
}

class _ProfileMobile extends StatelessWidget {
  final ProfileData profile;
  const _ProfileMobile({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: _ProfileContent(profile: profile),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final ProfileData profile;
  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Text(
                '${profile.firstName?[0] ?? ''}${profile.lastName?[0] ?? ''}'.toUpperCase(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${profile.firstName} ${profile.lastName}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  profile.email ?? '',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 40),

        // Info Sections
        const Text(
          'Información Académica',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        NexusCard(
          child: Column(
            children: [
              _InfoRow(label: 'Rol', value: profile.role?['name'] ?? 'Usuario'),
              const Divider(),
              _InfoRow(label: 'Centro Educativo', value: 'Instituto de Pruebas ClassNexus'),
              const Divider(),
              _InfoRow(label: 'Ciclo', value: '2º DAW - Desarrollo de Aplicaciones Web'),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Security Section
        const Text(
          'Seguridad',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        NexusCard(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.lock_outline, color: Colors.blue),
                title: const Text('Cambiar Contraseña'),
                subtitle: const Text('Se recomienda usar una contraseña segura de al menos 8 caracteres.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showChangePasswordDialog(context),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.notifications_outlined, color: Colors.orange),
                title: const Text('Notificaciones'),
                subtitle: const Text('Gestionar alertas de tareas y mensajes.'),
                trailing: Switch(value: true, onChanged: (_) {}),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
