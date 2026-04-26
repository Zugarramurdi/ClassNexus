import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/features/subjects/providers/subjects_provider.dart';

class AdminSubjectsNotifier extends AsyncNotifier<List<SubjectData>> {
  @override
  Future<List<SubjectData>> build() async {
    return _fetchSubjects();
  }

  Future<List<SubjectData>> _fetchSubjects() async {
    final supabase = ref.read(supabaseClientProvider);
    try {
      final response = await supabase
          .from('subjects')
          .select('*, center:centers(*)')
          .order('name');
      
      return (response as List).map((json) => SubjectData.fromJson(json)).toList();
    } catch (e) {
      print('Error en AdminSubjectsNotifier._fetchSubjects: $e');
      rethrow;
    }
  }

  Future<void> createSubject({
    required String name,
    required int centerId,
    String? description,
  }) async {
    state = const AsyncLoading();
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/admin/subjects', data: {
        'name': name,
        'center_id': centerId,
        'description': description,
      });
      ref.invalidate(subjectsProvider); // Actualizar también el provider general
      state = AsyncData(await _fetchSubjects());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateSubject({
    required int id,
    required String name,
    String? description,
  }) async {
    state = const AsyncLoading();
    try {
      final dio = ref.read(dioProvider);
      await dio.put('/admin/subjects/$id', data: {
        'name': name,
        'description': description,
      });
      ref.invalidate(subjectsProvider);
      state = AsyncData(await _fetchSubjects());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteSubject(int id) async {
    state = const AsyncLoading();
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/admin/subjects/$id');
      ref.invalidate(subjectsProvider);
      state = AsyncData(await _fetchSubjects());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final adminSubjectsProvider = AsyncNotifierProvider<AdminSubjectsNotifier, List<SubjectData>>(() {
  return AdminSubjectsNotifier();
});
