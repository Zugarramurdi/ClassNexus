import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/widgets/nexus_sidebar.dart';
import 'package:frontend/core/widgets/responsive_layout.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: ResponsiveLayout(
        // En móvil usamos Drawer
        mobile: Scaffold(
          appBar: AppBar(
            title: Image.asset('assets/logos/ClassNexus-logo-2.png', height: 32),
          ),
          drawer: Drawer(
            child: NexusSidebar(currentPath: currentPath),
          ),
          body: child,
        ),
        // En escritorio el Sidebar es fijo
        desktop: Row(
          children: [
            NexusSidebar(currentPath: currentPath),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
