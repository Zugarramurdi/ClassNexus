import 'package:flutter/material.dart';

class AdminShell extends StatelessWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Definimos el breakpoint para escritorio
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            const _AdminSidebar(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : const _AdminBottomNav(),
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'CLASSNEXUS',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const Divider(),
          _AdminNavItem(
            icon: Icons.business,
            label: 'CENTROS',
            onTap: () {},
          ),
          _AdminNavItem(
            icon: Icons.school,
            label: 'PROFESORES',
            onTap: () {},
          ),
          _AdminNavItem(
            icon: Icons.person,
            label: 'ALUMNOS',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AdminNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      onTap: onTap,
    );
  }
}

class _AdminBottomNav extends StatelessWidget {
  const _AdminBottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.business), label: 'CENTROS'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'PROFESORES'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'ALUMNOS'),
      ],
    );
  }
}
