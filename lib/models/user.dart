class User {
  final String id;
  final String? email;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String role;
  final String? avatarUrl;
  final String? dateOfBirth;
  final String? gender;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final bool isActive;
  final String createdAt;

  User({
    required this.id,
    this.email,
    this.phone,
    this.firstName,
    this.lastName,
    this.role = 'passenger',
    this.avatarUrl,
    this.dateOfBirth,
    this.gender,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.isActive = true,
    this.createdAt = '',
  });

  String get fullName => [firstName, lastName].where((s) => s != null && s.isNotEmpty).join(' ');
  String get initials => '${(firstName ?? '').isNotEmpty ? firstName![0] : ''}${(lastName ?? '').isNotEmpty ? lastName![0] : ''}'.toUpperCase();

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? '',
    email: json['email'],
    phone: json['phone'],
    firstName: json['first_name'],
    lastName: json['last_name'],
    role: json['role'] ?? 'passenger',
    avatarUrl: json['avatar_url'],
    dateOfBirth: json['date_of_birth'],
    gender: json['gender'],
    emergencyContactName: json['emergency_contact_name'],
    emergencyContactPhone: json['emergency_contact_phone'],
    isActive: json['is_active'] ?? true,
    createdAt: json['created_at'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'phone': phone,
    'first_name': firstName,
    'last_name': lastName,
    'role': role,
    'avatar_url': avatarUrl,
    'date_of_birth': dateOfBirth,
    'gender': gender,
    'emergency_contact_name': emergencyContactName,
    'emergency_contact_phone': emergencyContactPhone,
    'is_active': isActive,
    'created_at': createdAt,
  };
}
