import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/dashboard/presentation/widgets/user_card.dart';

class NexusSidebar extends ConsumerWidget {
  final String currentPath;

  const NexusSidebar({
    super.key,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          
          // Navigation Items
          _SidebarItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            isActive: currentPath == '/dashboard',
            onTap: () => context.go('/dashboard'),
          ),
          _SidebarItem(
            icon: Icons.school_outlined,
            label: 'Asignaturas',
            isActive: currentPath.startsWith('/subjects'),
            onTap: () => context.go('/subjects'),
          ),
          _SidebarItem(
            icon: Icons.calendar_today_outlined,
            label: 'Horario',
            isActive: currentPath == '/schedule',
            onTap: () {},
          ),
          _SidebarItem(
            icon: Icons.chat_bubble_outline,
            label: 'Mensajes',
            isActive: currentPath == '/messages',
            onTap: () {},
          ),
          
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
