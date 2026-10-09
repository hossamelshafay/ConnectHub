import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a portfolio project under users/{uid}/projects/{projectId}.
class ProjectModel {
  final String id;
  final String title;
  final String description;
  final List<String> technologies;
  final String? projectUrl;
  final String? githubUrl;
  final String? imageUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isFeatured;
  final bool isVisible;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    this.technologies = const [],
    this.projectUrl,
    this.githubUrl,
    this.imageUrl,
    this.startDate,
    this.endDate,
    this.isFeatured = false,
    this.isVisible = true,
  });

  factory ProjectModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProjectModel.fromMap(data, id: doc.id);
  }

  factory ProjectModel.fromMap(Map<String, dynamic> data, {String? id}) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return ProjectModel(
      id: id ?? (data['id'] as String? ?? ''),
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      technologies: List<String>.from(data['technologies'] ?? []),
      projectUrl: data['projectUrl'] as String?,
      githubUrl: data['githubUrl'] as String?,
      imageUrl: data['imageUrl'] as String?,
      startDate: parseDate(data['startDate']),
      endDate: parseDate(data['endDate']),
      isFeatured: (data['isFeatured'] as bool?) ?? false,
      isVisible: (data['isVisible'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap({bool includeId = false}) => {
        if (includeId) 'id': id,
        'title': title,
        'description': description,
        'technologies': technologies,
        if (projectUrl != null) 'projectUrl': projectUrl,
        if (githubUrl != null) 'githubUrl': githubUrl,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (startDate != null) 'startDate': Timestamp.fromDate(startDate!),
        if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
        'isFeatured': isFeatured,
        'isVisible': isVisible,
      };
}
