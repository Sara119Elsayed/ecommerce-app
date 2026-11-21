class Auth {
  const Auth({
    required this.email,
    required this.password,
    this.id,
    this.username = '',
    this.token = '',
  });

  final String email;
  final String password;
  final int? id;
  final String username;
  final String token;

  factory Auth.fromJson(
    Map<String, dynamic> json, {
    String password = '',
  }) {
    return Auth(
      id: json['id'] is int ? json['id'] as int : null,
      email: json['email']?.toString() ?? '',
      password: password,
      username: json['username']?.toString() ?? '',
      token: json['accessToken']?.toString() ??
          json['token']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}