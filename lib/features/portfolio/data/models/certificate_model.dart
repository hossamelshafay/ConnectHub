import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a professional certificate or license under users/{uid}/certificates/{certificateId}.
class CertificateModel {
  final String id;
  final String title;
  final String issuingOrganization;
  final DateTime? issueDate;
  final DateTime? expirationDate;
  final String? credentialId;
  final String? credentialUrl;
  final bool isVisible;

  const CertificateModel({
    required this.id,
    required this.title,
    required this.issuingOrganization,
    this.issueDate,
    this.expirationDate,
    this.credentialId,
    this.credentialUrl,
    this.isVisible = true,
  });

  factory CertificateModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CertificateModel.fromMap(data, id: doc.id);
  }

  factory CertificateModel.fromMap(Map<String, dynamic> data, {String? id}) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return CertificateModel(
      id: id ?? (data['id'] as String? ?? ''),
      title: data['title'] as String? ?? '',
      issuingOrganization: data['issuingOrganization'] as String? ?? '',
      issueDate: parseDate(data['issueDate']),
      expirationDate: parseDate(data['expirationDate']),
      credentialId: data['credentialId'] as String?,
      credentialUrl: data['credentialUrl'] as String?,
      isVisible: (data['isVisible'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap({bool includeId = false}) => {
        if (includeId) 'id': id,
        'title': title,
        'issuingOrganization': issuingOrganization,
        if (issueDate != null) 'issueDate': Timestamp.fromDate(issueDate!),
        if (expirationDate != null)
          'expirationDate': Timestamp.fromDate(expirationDate!),
        if (credentialId != null) 'credentialId': credentialId,
        if (credentialUrl != null) 'credentialUrl': credentialUrl,
        'isVisible': isVisible,
      };
}
