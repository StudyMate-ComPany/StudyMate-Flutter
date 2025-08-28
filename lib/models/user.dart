class User {
  final String id;
  final String email;
  final String name;
  final String? bio;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? preferences;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.bio,
    this.avatarUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.preferences,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      name: json['profile_name'] ?? json['name'] ?? json['username'] ?? '',
      bio: json['bio'],
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.tryParse(json['date_joined'] ?? json['created_at'] ?? '') ?? DateTime.now(),
      lastLoginAt: json['last_login'] != null 
          ? DateTime.tryParse(json['last_login']) 
          : json['last_login_at'] != null
              ? DateTime.tryParse(json['last_login_at'])
              : null,
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'bio': bio,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'preferences': preferences,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? bio,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
    );
  }
}