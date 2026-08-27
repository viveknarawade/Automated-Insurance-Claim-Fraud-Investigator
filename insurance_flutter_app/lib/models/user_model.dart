class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? phoneNumber;
  final bool? isVerified;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? json['name'] ?? 'User',
      email: json['email'] ?? '',
      role: json['role'] ?? 'USER',
      phoneNumber: json['phoneNumber'],
      isVerified: json['verified'] ?? json['isVerified'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
      'verified': isVerified,
    };
  }
}
