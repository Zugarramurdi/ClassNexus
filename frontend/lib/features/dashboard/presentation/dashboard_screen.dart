import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/widgets/nexus_card.dart';
import 'package:frontend/core/widgets/responsive_layout.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/features/profile/providers/profile_provider.dart';
import 'package:frontend/core/theme/app_colors.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (profile) {
          if (profile == null) return const Center(child: Text('Perfil no encontrado'));

          final isTeacher = profile.role?['name']?.toString().toLowerCase() == 'profesor';

          return ResponsiveLayout(
            mobile: _DashboardMobile(profile: profile, isTeacher: isTeacher),
            desktop: _DashboardDesktop(profile: profile, isTeacher: isTeacher),
          );
        },
      ),
    );
  }
}

class _DashboardDesktop extends ConsumerWidget {
  final dynamic profile;
  final bool isTeacher;

  const _DashboardDesktop({required this.profile, required this.isTeacher});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Sidebar Lateral
        Container(
          width: 260,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.02),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Image.asset('assets/logos/ClassNexus-logo.png'),
              ),
              const SizedBox(height: 16),
              _SidebarItem(icon: Icons.dashboard_outlined, label: 'Dashboard', isActive: true, onTap: () {}),
              _SidebarItem(icon: Icons.school_outlined, label: 'Asignaturas', onTap: () => context.push('/subjects')),
              _SidebarItem(icon: Icons.calendar_today_outlined, label: 'Horario', onTap: () {}),
              _SidebarItem(icon: Icons.chat_bubble_outline, label: 'Mensajes', onTap: () {}),
              const Spacer(),
              _SidebarItem(
                icon: Icons.logout, 
                label: 'Cerrar Sesión', 
                onTap: () => ref.read(authNotifierProvider.notifier).signOut()
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        
        // Contenido Principal
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(40.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _DashboardHeader(profile: profile),
                    const SizedBox(height: 40),
                    if (isTeacher) 
                      _TeacherStatsGrid()
                    else 
                      _StudentSubjectsGrid(),
                    const SizedBox(height: 40),
                    _RecentActivitySection(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardMobile extends ConsumerWidget {
  final dynamic profile;
  final bool isTeacher;

  const _DashboardMobile({required this.profile, required this.isTeacher});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logos/ClassNexus-logo-2.png', height: 32),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DashboardHeader(profile: profile),
            const SizedBox(height: 32),
            if (isTeacher) 
              _TeacherStatsGrid()
            else 
              _StudentSubjectsGrid(),
            const SizedBox(height: 32),
            _RecentActivitySection(),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final dynamic profile;
  const _DashboardHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, ${profile.firstName}',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Aquí tienes un resumen de tu actividad académica.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _StudentSubjectsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tus Asignaturas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: ResponsiveLayout.isDesktop(context) ? 3 : 1,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _SubjectCard(title: 'Programación Multimedia', subtitle: '2º DAM', color: Colors.teal),
            _SubjectCard(title: 'Desarrollo de Interfaces', subtitle: '2º DAM', color: Colors.indigo),
            _SubjectCard(title: 'Acceso a Datos', subtitle: '2º DAM', color: Colors.orange),
          ],
        ),
      ],
    );
  }
}

class _TeacherStatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: ResponsiveLayout.isDesktop(context) ? 4 : 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _StatCard(label: 'Alumnos', value: '124', icon: Icons.people_alt_outlined),
        _StatCard(label: 'Tareas Pendientes', value: '12', icon: Icons.assignment_late_outlined),
        _StatCard(label: 'Grupos', value: '4', icon: Icons.groups_outlined),
        _StatCard(label: 'Mensajes', value: '5', icon: Icons.mail_outline),
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Text(label, style: TextStyle(color: color, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _SubjectCard({required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return NexusCard(
      onTap: () {},
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.book_outlined, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return NexusCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Actividad Reciente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        NexusCard(
          child: Column(
            children: [
              _ActivityItem(title: 'Tarea entregada: Examen Programación', time: 'Hace 2 horas', icon: Icons.check_circle_outline, color: Colors.green),
              const Divider(),
              _ActivityItem(title: 'Nueva nota disponible en Acceso a Datos', time: 'Ayer', icon: Icons.grade_outlined, color: Colors.orange),
              const Divider(),
              _ActivityItem(title: 'Mensaje de Profesor DAM', time: 'Hace 2 días', icon: Icons.message_outlined, color: Colors.blue),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final Color color;

  const _ActivityItem({required this.title, required this.time, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(time, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

