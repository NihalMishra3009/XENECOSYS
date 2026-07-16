class UserAccount {
  const UserAccount({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String fullName;
  final String email;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserAccount copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserAccount(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserAccount.fromMap(Map<String, Object?> map) {
    return UserAccount(
      id: map['id'] as int?,
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, Object?> toInsertMap() {
    return {
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, Object?> toUpdateMap() {
    return {
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
