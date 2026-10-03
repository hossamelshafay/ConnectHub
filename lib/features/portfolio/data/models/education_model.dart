import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents an education record under users/{uid}/education/{educationId}.
class EducationModel {
  final String id;
  final String institution;
  final String degree;
  final String? fieldOfStudy;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? grade;
  final String? activities;
  final String? description;
  final bool isVisible;

  const EducationModel({
    required this.id,
    required this.institution,
    required this.degree,
    this.fieldOfStudy,
    this.startDate,
    this.endDate,
    this.grade,
    this.activities,
    this.description,
    this.isVisible = true,
  });

  factory EducationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return EducationModel(
      id: doc.id,
      institution: data['institution'] as String? ?? '',
      degree: data['degree'] as String? ?? '',
      fieldOfStudy: data['fieldOfStudy'] as String?,
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      grade: data['grade'] as String?,
      activities: data['activities'] as String?,
      description: data['description'] as String?,
      isVisible: (data['isVisible'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'institution': institution,
        'degree': degree,
        if (fieldOfStudy != null) 'fieldOfStudy': fieldOfStudy,
        if (startDate != null) 'startDate': Timestamp.fromDate(startDate!),
        if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
        if (grade != null) 'grade': grade,
        if (activities != null) 'activities': activities,
        if (description != null) 'description': description,
        'isVisible': isVisible,
      };
}
