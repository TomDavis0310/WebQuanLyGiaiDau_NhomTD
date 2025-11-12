import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String userName;
  final String? fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? profilePictureUrl;
  final DateTime? createdAt;
  final String? role;

  User({
    required this.id,
    required this.email,
    required this.userName,
    this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.profilePictureUrl,
    this.createdAt,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Copy with method for updating user info
  User copyWith({
    String? id,
    String? email,
    String? userName,
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? profilePictureUrl,
    DateTime? createdAt,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
    );
  }
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;
  final bool rememberMe;

  LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => 
      _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String email;
  final String userName;
  final String password;
  final String confirmPassword;
  final String? fullName;
  final String? phoneNumber;

  RegisterRequest({
    required this.email,
    required this.userName,
    required this.password,
    required this.confirmPassword,
    this.fullName,
    this.phoneNumber,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => 
      _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final User? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => 
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
