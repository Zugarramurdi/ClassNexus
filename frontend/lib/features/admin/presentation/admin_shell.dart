import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/features/admin/presentation/cycles/cycles_list_page.dart';
import 'package:frontend/features/admin/presentation/subjects/subjects_list_page.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Definimos el breakpoint para escritorio
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final location = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            _AdminSidebar(currentPath: location, ref: ref),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : _AdminBottomNav(currentPath: location),
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  final String currentPath;
  final WidgetRef ref;
  const _AdminSidebar({required this.currentPath, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.02),
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Image.asset('assets/logos/ClassNexus-logo.png'),
          ),
          const Divider(),
          _AdminNavItem(
            icon: Icons.business,
            label: 'CENTROS',
            isActive: currentPath.startsWith('/admin/centers'),
            onTap: () => context.go('/admin/centers'),
          ),
          _AdminNavItem(
            icon: Icons.school,
            label: 'PROFESORES',
            isActive: currentPath.startsWith('/admin/teachers'),
            onTap: () => context.go('/admin/teachers'),
          ),
          _AdminNavItem(
            icon: Icons.person,
            label: 'ALUMNOS',
            isActive: currentPath.startsWith('/admin/students'),
            onTap: () => context.go('/admin/students'),
          ),
          const Divider(),
          _AdminNavItem(
            icon: Icons.auto_stories,
            label: 'CICLOS',
            isActive: currentPath.startsWith('/admin/cycles'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCyclesListPage())),
          ),
          _AdminNavItem(
            icon: Icons.book,
            label: 'ASIGNATURAS',
            isActive: currentPath.startsWith('/admin/subjects'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSubjectsListPage())),
          ),
          const Spacer(),
          const Divider(),
          _AdminNavItem(
            icon: Icons.logout,
            label: 'CERRAR SESIÓN',
            isActive: false,
            onTap: () {
              ref.read(authNotifierProvider.notifier).signOut();
              context.go('/');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _AdminNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive 
        ? Theme.of(context).colorScheme.primary 
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.7);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: color, size: 22),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600, 
            fontSize: 13,
            color: color,
          ),
        ),
        selected: isActive,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        onTap: onTap,
      ),
    );
  }
}

class _AdminBottomNav extends StatelessWidget {
  final String currentPath;
  const _AdminBottomNav({required this.currentPath});

  int _getSelectedIndex() {
    if (currentPath.startsWith('/admin/centers')) return 0;
    if (currentPath.startsWith('/admin/teachers')) return 1;
    if (currentPath.startsWith('/admin/students')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _getSelectedIndex(),
      onTap: (index) {
        if (index == 0) context.go('/admin/centers');
        if (index == 1) context.go('/admin/teachers');
        if (index == 2) context.go('/admin/students');
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.business), label: 'CENTROS'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'PROFESORES'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'ALUMNOS'),
      ],
    );
  }
}
