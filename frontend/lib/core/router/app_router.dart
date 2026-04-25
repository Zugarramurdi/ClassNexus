import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/auth/presentation/login_screen.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/features/dashboard/presentation/dashboard_screen.dart';
import 'package:frontend/features/subjects/presentation/subjects_screen.dart';
import 'package:frontend/features/subjects/presentation/subject_detail_screen.dart';
import 'package:frontend/features/subjects/presentation/task_detail_screen.dart';
import 'package:frontend/features/subjects/models/assignment_data.dart';

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
      GoRoute(
        path: '/subjects',
        builder: (context, state) => const SubjectsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => SubjectDetailScreen(
              subjectId: state.pathParameters['id']!,
            ),
            routes: [
              GoRoute(
                path: 'tasks/:taskId',
                builder: (context, state) => TaskDetailScreen(
                  assignment: state.extra as AssignmentData,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
