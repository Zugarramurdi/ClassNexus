import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // If we are still waiting for auth state, do nothing
      if (authState.isLoading) return null;

      final isAuth = authState.value?.session != null;
      final isLoggingIn = state.uri.path == '/';

      if (!isAuth && !isLoggingIn) return '/';
      if (isAuth && isLoggingIn) return '/dashboard';
      
      return null; // No redirection needed
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
});
