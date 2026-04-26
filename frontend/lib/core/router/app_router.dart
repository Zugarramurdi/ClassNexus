import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/auth/presentation/login_screen.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/features/dashboard/presentation/dashboard_screen.dart';
import 'package:frontend/features/subjects/presentation/subjects_screen.dart';
import 'package:frontend/features/subjects/presentation/subject_detail_screen.dart';
import 'package:frontend/features/subjects/presentation/task_detail_screen.dart';
import 'package:frontend/features/subjects/models/assignment_data.dart';
import 'package:frontend/features/admin/presentation/admin_shell.dart';
import 'package:frontend/features/admin/presentation/centers/centers_screen.dart';
import 'package:frontend/features/admin/presentation/centers/center_form_page.dart';
import 'package:frontend/features/admin/presentation/users/teachers_screen.dart';
import 'package:frontend/features/admin/presentation/users/students_screen.dart';
import 'package:frontend/features/admin/presentation/users/user_form_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (authState.isLoading) return null;

      final isAuth = authState.value?.session != null;
      final isLoggingIn = state.uri.path == '/';
      final isAdminPath = state.uri.path.startsWith('/admin');

      // Permitir el acceso a rutas de admin si se solicita explícitamente (Bypass)
      if (isAdminPath) return null;

      if (!isAuth && !isLoggingIn) return '/';
      if (isAuth && isLoggingIn) return '/dashboard';
      
      return null;
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
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin/centers',
            builder: (context, state) => const CentersScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const CenterFormPage(),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/teachers',
            builder: (context, state) => const TeachersScreen(),
          ),
          GoRoute(
            path: '/admin/students',
            builder: (context, state) => const StudentsScreen(),
          ),
          GoRoute(
            path: '/admin/users/new',
            builder: (context, state) {
              final roleId = int.tryParse(state.uri.queryParameters['role'] ?? '2') ?? 2;
              return UserFormPage(roleId: roleId);
            },
          ),
        ],
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
