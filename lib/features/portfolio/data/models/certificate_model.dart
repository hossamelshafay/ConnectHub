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
    return CertificateModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      issuingOrganization: data['issuingOrganization'] as String? ?? '',
      issueDate: (data['issueDate'] as Timestamp?)?.toDate(),
      expirationDate: (data['expirationDate'] as Timestamp?)?.toDate(),
      credentialId: data['credentialId'] as String?,
      credentialUrl: data['credentialUrl'] as String?,
      isVisible: (data['isVisible'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
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
