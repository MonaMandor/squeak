
class LoginData {
  final String token;
  final String refreshToken;
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final int role;

  const LoginData({
    required this.token,
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.refreshToken,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'],
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      refreshToken: json['refreshToken'],
    );
  }
}
