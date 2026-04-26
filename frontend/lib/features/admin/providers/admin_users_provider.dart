import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/features/profile/providers/profile_provider.dart';

class AdminUsersNotifier extends AsyncNotifier<List<ProfileData>> {
  @override
  Future<List<ProfileData>> build() async {
    return _fetchUsers();
  }

  Future<List<ProfileData>> _fetchUsers() async {
    final supabase = ref.read(supabaseClientProvider);
    try {
      // Obtenemos todos los perfiles con sus roles y centros asociados
      final response = await supabase
          .from('profiles')
          .select('*, role:roles(*), teachingSubjects:profile_subject(subject_id)')
          .order('last_name');
      
      return (response as List).map((json) => ProfileData.fromJson(json)).toList();
    } catch (e) {
      print('Error en AdminUsersNotifier._fetchUsers: $e');
      rethrow;
    }
  }

  Future<void> createUser({
    required String email,
    required String firstName,
    required String lastName,
    required int roleId,
    int? centerId,
    String? tutorId,
    List<int>? subjectIds,
  }) async {
    state = const AsyncLoading();
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/admin/users', data: {
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'role_id': roleId,
        'center_id': centerId,
        'tutor_id': tutorId,
        'subject_ids': subjectIds,
      });
      
      ref.invalidate(profileProvider); // Invalidar el perfil actual por si acaso
      state = AsyncData(await _fetchUsers());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateUser({
    required String id,
    required String firstName,
    required String lastName,
    int? centerId,
    String? tutorId,
    List<int>? subjectIds,
  }) async {
    state = const AsyncLoading();
    try {
      final dio = ref.read(dioProvider);
      await dio.put('/admin/users/$id', data: {
        'first_name': firstName,
        'last_name': lastName,
        'center_id': centerId,
        'tutor_id': tutorId,
        'subject_ids': subjectIds,
      });
      
      ref.invalidate(profileProvider);
      state = AsyncData(await _fetchUsers());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteUser(String id) async {
    state = const AsyncLoading();
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/admin/users/$id');
      ref.invalidate(profileProvider);
      state = AsyncData(await _fetchUsers());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final adminUsersProvider = AsyncNotifierProvider<AdminUsersNotifier, List<ProfileData>>(() {
  return AdminUsersNotifier();
});
