class SubmissionData {
  final int id;
  final int assignmentId;
  final String studentId;
  final String? fileUrl;
  final String? linkUrl;
  final String? studentComment;
  final double? score;
  final String? feedback;
  final Map<String, dynamic>? student;

  SubmissionData({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    this.fileUrl,
    this.linkUrl,
    this.studentComment,
    this.score,
    this.feedback,
    this.student,
  });

  factory SubmissionData.fromJson(Map<String, dynamic> json) {
    return SubmissionData(
      id: json['id'],
      assignmentId: json['assignment_id'],
      studentId: json['student_id'],
      fileUrl: json['file_url'],
      linkUrl: json['link_url'],
      studentComment: json['student_comment'],
      score: json['score'] != null ? double.tryParse(json['score'].toString()) : null,
      feedback: json['feedback'],
      student: json['student'],
    );
  }
}
