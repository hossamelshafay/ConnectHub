class SavedAccountModel {
  final String uid;
  final String email;
  final String displayName;
  final String username;
  final String profileImage;
  final DateTime lastUsedAt;

  SavedAccountModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.username,
    required this.profileImage,
    DateTime? lastUsedAt,
  }) : lastUsedAt = lastUsedAt ?? DateTime.now();

  SavedAccountModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? username,
    String? profileImage,
    DateTime? lastUsedAt,
  }) {
    return SavedAccountModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      profileImage: profileImage ?? this.profileImage,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'username': username,
      'profileImage': profileImage,
      'lastUsedAt': lastUsedAt.toIso8601String(),
    };
  }

  factory SavedAccountModel.fromJson(Map<String, dynamic> json) {
    return SavedAccountModel(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      profileImage: json['profileImage'] as String? ?? '',
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.tryParse(json['lastUsedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
