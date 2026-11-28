class Profile {
  const Profile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
    required this.image,
    required this.age,
    required this.gender,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.company,
    required this.role,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phone;
  final String image;
  final int age;
  final String gender;
  final String address;
  final String city;
  final String state;
  final String country;
  final String company;
  final String role;

  String get fullName => '$firstName $lastName'.trim();

  factory Profile.fromJson(Map<String, dynamic> json) {
    final addressData = _asMap(json['address']);
    final companyData = _asMap(json['company']);
    return Profile(
      id: _asInt(json['id']),
      firstName: _asString(json['firstName']),
      lastName: _asString(json['lastName']),
      username: _asString(json['username']),
      email: _asString(json['email']),
      phone: _asString(json['phone']),
      image: _asString(json['image']),
      age: _asInt(json['age']),
      gender: _asString(json['gender']),
      address: _asString(addressData['address']),
      city: _asString(addressData['city']),
      state: _asString(addressData['state']),
      country: _asString(addressData['country']),
      company: _asString(companyData['name']),
      role: _asString(companyData['title']),
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    return value is Map<String, dynamic> ? value : const {};
  }

  static String _asString(dynamic value) => value?.toString() ?? '';

  static int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
