class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final String role; // 'consumer', 'supplier', etc.
  
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    required this.role,
  });
  
  // From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profile_picture'],
      role: json['role'] ?? 'consumer',
    );
  }
  
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_picture': profilePicture,
      'role': role,
    };
  }
  
  // Copy with
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePicture,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
    );
  }
}