import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';

class CycleData {
  final int id;
  final String name;
  final String? description;
  final int? centerId;
  final List<int>? subjectIds;

  CycleData({
    required this.id,
    required this.name,
    this.description,
    this.centerId,
    this.subjectIds,
  });

  factory CycleData.fromJson(Map<String, dynamic> json) {
    List<int>? subjects;
    if (json['subjects'] != null) {
      subjects = (json['subjects'] as List)
          .map((s) => int.parse(s['id'].toString()))
          .toList();
    } else if (json['cycle_subject'] != null) {
      // Formato alternativo si viene de Supabase JOIN directo
      subjects = (json['cycle_subject'] as List)
          .map((s) => int.parse(s['subject_id'].toString()))
          .toList();
    }

    return CycleData(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      description: json['description'],
      centerId: json['center_id'] != null ? int.parse(json['center_id'].toString()) : null,
      subjectIds: subjects,
    );
  }
}

class CyclesNotifier extends AsyncNotifier<List<CycleData>> {
  @override
  Future<List<CycleData>> build() async {
    return _fetchCycles();
  }

  Future<List<CycleData>> _fetchCycles() async {
    final supabase = ref.read(supabaseClientProvider);
    try {
      final response = await supabase
          .from('cycles')
          .select('*, cycle_subject(subject_id)')
          .order('name');
      
      return (response as List).map((json) => CycleData.fromJson(json)).toList();
    } catch (e) {
      print('Error en CyclesNotifier._fetchCycles: $e');
      rethrow;
    }
  }

  Future<void> createCycle({
    required String name,
    required int centerId,
    String? description,
    List<int>? subjectIds,
  }) async {
    state = const AsyncLoading();
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/admin/cycles', data: {
        'name': name,
        'center_id': centerId,
        'description': description,
        'subject_ids': subjectIds,
      });
      state = AsyncData(await _fetchCycles());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateCycle({
    required int id,
    required String name,
    String? description,
    List<int>? subjectIds,
  }) async {
    state = const AsyncLoading();
    try {
      final dio = ref.read(dioProvider);
      await dio.put('/admin/cycles/$id', data: {
        'name': name,
        'description': description,
        'subject_ids': subjectIds,
      });
      state = AsyncData(await _fetchCycles());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteCycle(int id) async {
    state = const AsyncLoading();
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/admin/cycles/$id');
      state = AsyncData(await _fetchCycles());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final cyclesProvider = AsyncNotifierProvider<CyclesNotifier, List<CycleData>>(() {
  return CyclesNotifier();
});
