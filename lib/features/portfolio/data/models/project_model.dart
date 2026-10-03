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
    return ProjectModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      technologies: List<String>.from(data['technologies'] ?? []),
      projectUrl: data['projectUrl'] as String?,
      githubUrl: data['githubUrl'] as String?,
      imageUrl: data['imageUrl'] as String?,
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      isFeatured: (data['isFeatured'] as bool?) ?? false,
      isVisible: (data['isVisible'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
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
