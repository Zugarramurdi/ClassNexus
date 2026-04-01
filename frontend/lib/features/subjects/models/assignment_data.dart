import 'submission_data.dart';

class AssignmentData {
  final int id;
  final int subjectId;
  final String title;
  final String description;
  final String? fileUrl;
  final DateTime dueDate;
  final double maxScore;
  final int? submissionsCount;
  final List<SubmissionData>? submissions;

  AssignmentData({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.description,
    this.fileUrl,
    required this.dueDate,
    required this.maxScore,
    this.submissionsCount,
    this.submissions,
  });

  factory AssignmentData.fromJson(Map<String, dynamic> json) {
    return AssignmentData(
      id: json['id'],
      subjectId: json['subject_id'],
      title: json['title'],
      description: json['description'],
      fileUrl: json['file_url'],
      dueDate: DateTime.parse(json['due_date']),
      maxScore: double.tryParse((json['max_score'] ?? '10.0').toString()) ?? 10.0,
      submissionsCount: json['submissions_count'],
      submissions: json['submissions'] != null 
          ? (json['submissions'] as List).map((e) => SubmissionData.fromJson(e)).toList()
          : null,
    );
  }
}
