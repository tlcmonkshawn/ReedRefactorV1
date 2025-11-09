class User {
  final int id;
  final String email;
  final String name;
  final String role;
  final int totalPoints;
  final int totalItemsScanned;
  final String? phoneNumber;
  final String? avatarUrl;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.totalPoints,
    required this.totalItemsScanned,
    this.phoneNumber,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      totalPoints: json['total_points'] as int? ?? 0,
      totalItemsScanned: json['total_items_scanned'] as int? ?? 0,
      phoneNumber: json['phone_number'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'total_points': totalPoints,
      'total_items_scanned': totalItemsScanned,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
    };
  }

  bool get isAgent => role == 'agent';
  bool get isBootieBoss => role == 'bootie_boss';
  bool get isAdmin => role == 'admin';
  bool get isPlayer => role == 'player';
  bool get canFinalize => isBootieBoss || isAdmin;
}

