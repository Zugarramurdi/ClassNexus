import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/auth/presentation/login_screen.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/features/dashboard/presentation/dashboard_screen.dart';
import 'package:frontend/features/subjects/presentation/subjects_screen.dart';
import 'package:frontend/features/subjects/presentation/subject_detail_screen.dart';
import 'package:frontend/features/subjects/presentation/task_detail_screen.dart';
import 'package:frontend/features/subjects/models/assignment_data.dart';
import 'package:frontend/features/subjects/presentation/assignment_submissions_screen.dart';
import 'package:frontend/features/admin/presentation/admin_shell.dart';
import 'package:frontend/features/admin/presentation/centers/centers_screen.dart';
import 'package:frontend/features/admin/presentation/centers/center_form_page.dart';
import 'package:frontend/features/admin/presentation/users/teachers_screen.dart';
import 'package:frontend/features/admin/presentation/users/students_screen.dart';
import 'package:frontend/features/admin/presentation/users/user_form_page.dart';
import 'package:frontend/features/admin/presentation/cycles/cycles_list_page.dart';
import 'package:frontend/features/admin/presentation/cycles/cycle_form_page.dart';
import 'package:frontend/features/admin/presentation/subjects/subjects_list_page.dart';
import 'package:frontend/features/admin/presentation/subjects/subject_form_page.dart';
import 'package:frontend/features/profile/presentation/profile_screen.dart';
import 'package:frontend/features/dashboard/presentation/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (authState.isLoading) return null;

      final isAuth = authState.value?.session != null;
      final isLoggingIn = state.uri.path == '/';
      final isAdminPath = state.uri.path.startsWith('/admin');

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
      // Shell para las rutas principales de usuario
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/subjects',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SubjectsScreen(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: SubjectDetailScreen(
                    subjectId: state.pathParameters['id']!,
                  ),
                ),
                routes: [
                  GoRoute(
                    path: 'tasks/:taskId',
                    pageBuilder: (context, state) => NoTransitionPage(
                      child: TaskDetailScreen(
                        assignment: state.extra as AssignmentData,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'submissions/:assignmentId',
                    pageBuilder: (context, state) => NoTransitionPage(
                      child: AssignmentSubmissionsScreen(
                        assignment: state.extra as AssignmentData,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Shell para Admin
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
          GoRoute(
            path: '/admin/cycles',
            builder: (context, state) => const AdminCyclesListPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const CycleFormPage(),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/subjects',
            builder: (context, state) => const AdminSubjectsListPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const SubjectFormPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
