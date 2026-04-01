class TopicData {
  final int id;
  final int subjectId;
  final String title;
  final String? description;
  final String? fileUrl;
  final int order;
  final DateTime? createdAt;

  TopicData({
    required this.id,
    required this.subjectId,
    required this.title,
    this.description,
    this.fileUrl,
    required this.order,
    this.createdAt,
  });

  factory TopicData.fromJson(Map<String, dynamic> json) {
    return TopicData(
      id: json['id'],
      subjectId: json['subject_id'],
      title: json['title'],
      description: json['description'],
      fileUrl: json['file_url'],
      order: json['order'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }
}
