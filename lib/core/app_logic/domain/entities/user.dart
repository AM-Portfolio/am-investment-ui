import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Domain entity representing a user
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    @Default('') String phoneNumber,
    @Default('') String userName,
    @Default([]) List<String> roles,
    @Default(true) bool isActive,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _User;
  const User._();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Get user's full name
  String get fullName {
    final name = '$firstName $lastName'.trim();
    if (name.isNotEmpty) return name;
    if (userName.isNotEmpty) return userName;
    return email.split('@').first; // Use email prefix as fallback
  }

  /// Check if user has a specific role
  bool hasRole(String role) => roles.contains(role);

  /// Check if user is administrator
  bool get isAdmin => hasRole('admin');
}
