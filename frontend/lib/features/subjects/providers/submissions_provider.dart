import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/subjects/models/submission_data.dart';

// Provider para listar las entregas de una Tarea (normalmente para el profesor)
final submissionsProvider = FutureProvider.family<List<SubmissionData>, int>((ref, assignmentId) async {
  final dio = ref.watch(dioProvider);

  try {
    final response = await dio.get('/assignments/$assignmentId/submissions');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => SubmissionData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load submissions');
    }
  } catch (e) {
    throw Exception('Error loading submissions: $e');
  }
});

// Provider / Service manual para interactuar con envíos y calificaciones
class SubmissionsNotifier {
  final Ref ref;
  SubmissionsNotifier(this.ref);

  // Alumno envía la tarea subiendo la url de Supabase Storage, link o comentario
  Future<SubmissionData> createSubmission({
    required int assignmentId, 
    String? fileUrl,
    String? linkUrl,
    String? studentComment,
  }) async {
    final dio = ref.read(dioProvider);
    
    final response = await dio.post('/assignments/$assignmentId/submissions', data: {
      'assignment_id': assignmentId,
      'file_url': fileUrl,
      'link_url': linkUrl,
      'student_comment': studentComment,
    });

    if (response.statusCode == 201 || response.statusCode == 200) {
      ref.invalidate(submissionsProvider(assignmentId));
      return SubmissionData.fromJson(response.data);
    } else {
      throw Exception('Failed to submit assignment');
    }
  }

  // Profesor pone la nota
  Future<SubmissionData> gradeSubmission(int submissionId, double score, String feedback, int assignmentId) async {
    final dio = ref.read(dioProvider);
    
    final response = await dio.patch('/submissions/$submissionId/grade', data: {
      'score': score,
      'feedback': feedback,
    });

    if (response.statusCode == 200) {
      ref.invalidate(submissionsProvider(assignmentId));
      return SubmissionData.fromJson(response.data);
    } else {
      throw Exception('Failed to grade submission');
    }
  }
}

final submissionsNotifierProvider = Provider((ref) => SubmissionsNotifier(ref));
