import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/assignment_data.dart';

// Definimos el Provider de los Assignments
final assignmentsProvider = FutureProvider.family<List<AssignmentData>, int>((ref, subjectId) async {
  final dio = ref.watch(dioProvider);

  try {
    final response = await dio.get('/subjects/$subjectId/assignments');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => AssignmentData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load assignments');
    }
  } catch (e) {
    throw Exception('Error loading assignments: $e');
  }
});

// Definimos un Provider o Service manual para poder hacer el POST (crear tarea)
class AssignmentsNotifier {
  final Ref ref;
  AssignmentsNotifier(this.ref);

  Future<AssignmentData> createAssignment({
    required int subjectId,
    required String title,
    required String description,
    required DateTime dueDate,
    required double maxScore,
    String? fileUrl,
  }) async {
    final dio = ref.read(dioProvider);
    
    final response = await dio.post('/subjects/$subjectId/assignments', data: {
      'subject_id': subjectId,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'max_score': maxScore,
      'file_url': fileUrl,
    });

    if (response.statusCode == 201) {
      ref.invalidate(assignmentsProvider(subjectId));
      return AssignmentData.fromJson(response.data);
    } else {
      throw Exception('Failed to create assignment');
    }
  }
}

final assignmentsNotifierProvider = Provider((ref) => AssignmentsNotifier(ref));
