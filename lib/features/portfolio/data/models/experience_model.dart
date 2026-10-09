import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a professional experience record under users/{uid}/experience/{experienceId}.
class ExperienceModel {
  final String id;
  final String company;
  final String role;
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String description;
  final List<String> skills;
  final bool isVisible;

  const ExperienceModel({
    required this.id,
    required this.company,
    required this.role,
    this.location,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.description = '',
    this.skills = const [],
    this.isVisible = true,
  });

  factory ExperienceModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ExperienceModel.fromMap(data, id: doc.id);
  }

  factory ExperienceModel.fromMap(Map<String, dynamic> data, {String? id}) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return ExperienceModel(
      id: id ?? (data['id'] as String? ?? ''),
      company: data['company'] as String? ?? '',
      role: data['role'] as String? ?? '',
      location: data['location'] as String?,
      startDate: parseDate(data['startDate']),
      endDate: parseDate(data['endDate']),
      isCurrent: (data['isCurrent'] as bool?) ?? false,
      description: data['description'] as String? ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      isVisible: (data['isVisible'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap({bool includeId = false}) => {
        if (includeId) 'id': id,
        'company': company,
        'role': role,
        if (location != null) 'location': location,
        if (startDate != null) 'startDate': Timestamp.fromDate(startDate!),
        if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
        'isCurrent': isCurrent,
        'description': description,
        'skills': skills,
        'isVisible': isVisible,
      };
}
