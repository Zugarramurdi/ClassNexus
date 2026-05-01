import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/dashboard/presentation/widgets/user_card.dart';
import 'package:frontend/features/profile/providers/profile_provider.dart';

class NexusSidebar extends ConsumerWidget {
  final String currentPath;

  const NexusSidebar({
    super.key,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final isAdmin = profileAsync.maybeWhen(
      data: (profile) => profile?.role?['name']?.toString().toLowerCase() == 'admin',
      orElse: () => currentPath.startsWith('/admin'),
    );

    // Función auxiliar para navegar y cerrar el drawer si es necesario
    void navigate(String path) {
      context.go(path);
      // Si estamos en móvil (dentro de un Drawer), lo cerramos
      if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
        Navigator.of(context).pop();
      }
    }

    return Container(
      width: 260,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.02),
      child: Column(
        children: [
          // Logo Section
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Image.asset('assets/logos/ClassNexus-logo.png'),
          ),
          const SizedBox(height: 16),
          
          if (isAdmin) ...[
            _SidebarItem(
              icon: Icons.business,
              label: 'Centros',
              isActive: currentPath.startsWith('/admin/centers'),
              onTap: () => navigate('/admin/centers'),
            ),
            _SidebarItem(
              icon: Icons.school,
              label: 'Profesores',
              isActive: currentPath.startsWith('/admin/teachers'),
              onTap: () => navigate('/admin/teachers'),
            ),
            _SidebarItem(
              icon: Icons.person,
              label: 'Alumnos',
              isActive: currentPath.startsWith('/admin/students'),
              onTap: () => navigate('/admin/students'),
            ),
            _SidebarItem(
              icon: Icons.auto_stories,
              label: 'Ciclos',
              isActive: currentPath.startsWith('/admin/cycles'),
              onTap: () => navigate('/admin/cycles'),
            ),
            _SidebarItem(
              icon: Icons.book,
              label: 'Asignaturas',
              isActive: currentPath.startsWith('/admin/subjects'),
              onTap: () => navigate('/admin/subjects'),
            ),
          ] else ...[
            // Navigation Items for Students/Teachers
            _SidebarItem(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              isActive: currentPath == '/dashboard',
              onTap: () => navigate('/dashboard'),
            ),
            _SidebarItem(
              icon: Icons.school_outlined,
              label: 'Asignaturas',
              isActive: currentPath.startsWith('/subjects'),
              onTap: () => navigate('/subjects'),
            ),
            _SidebarItem(
              icon: Icons.calendar_today_outlined,
              label: 'Horario',
              isActive: currentPath == '/schedule',
              onTap: () => navigate('/schedule'),
            ),
            _SidebarItem(
              icon: Icons.chat_bubble_outline,
              label: 'Mensajes',
              isActive: currentPath == '/messages',
              onTap: () => navigate('/messages'),
            ),
          ],
          
          const Spacer(),
          
          // Identity Section (UserCard)
          const UserCard(),
          const SizedBox(height: 8),
        ],
      ),
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
    final color = isActive 
        ? Theme.of(context).colorScheme.primary 
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
