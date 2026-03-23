import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error al cargar perfil: $err')),
        data: (profile) {
          if (profile == null) {
            // El usuario existe en Auth pero no tiene registro en profiles (o backend falló en /me)
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text('Tu perfil está incompleto.', style: TextStyle(fontSize: 20)),
                  Text('Email: ${user?.email ?? ""}'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Navegar a pantalla de completar perfil
                    },
                    child: const Text('Completar mis datos'),
                  )
                ],
              ),
            );
          }

          // Perfil encontrado en Laravel
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bienvenido de vuelta,',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  '${profile.firstName ?? ""} ${profile.lastName ?? ""}'.trim().isEmpty 
                      ? 'Usuario ${profile.id.substring(0, 6)}' 
                      : '${profile.firstName} ${profile.lastName}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text((profile.role?['name'] ?? 'Sin Rol asignado').toString().toUpperCase()),
                  backgroundColor: Colors.blue.shade100,
                  side: BorderSide.none,
                ),
                const Divider(height: 48),
                const Text(
                  'Acciones Rápidas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Aquí irán las tarjetas dependiendo del rol
                Row(
                  children: [
                    _buildFeatureCard(
                      Icons.school, 
                      'Mis Asignaturas', 
                      Colors.purple,
                      onTap: () => context.push('/subjects'),
                    ),
                    const SizedBox(width: 16),
                    _buildFeatureCard(
                      Icons.calendar_month, 
                      'Horario', 
                      Colors.orange,
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, Color color, {VoidCallback? onTap}) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withOpacity(0.2)),
        ),
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Icon(icon, size: 48, color: color),
                const SizedBox(height: 16),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color.withOpacity(0.8))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

