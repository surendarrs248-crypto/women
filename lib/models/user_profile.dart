class UserProfile {
  String name;
  String phone;

  UserProfile({required this.name, required this.phone});

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String? ?? 'Ananya',
        phone: json['phone'] as String? ?? '+919900112233',
      );
}