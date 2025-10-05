import '../datasources/auth_data_source.dart';
import 'user_mapper.dart';

/// Mapper class to convert between Authentication data and domain entities
class AuthMapper {
  /// Parse API error response
  static String parseApiError(Map<String, dynamic> json) {
    // Basic error parsing without DTOs
    return json['message'] as String? ??
        json['error'] as String? ??
        json['errors']?[0] as String? ??
        'Unknown error occurred';
  }

  /// Convert AuthDataResponse from JSON (bypassing DTOs for simpler cases)
  static AuthDataResponse fromJson(Map<String, dynamic> json) =>
      AuthDataResponse(
        user: UserMapper.fromJson(json['user'] as Map<String, dynamic>),
        token: json['access_token'] as String? ?? json['token'] as String,
        refreshToken: json['refresh_token'] as String?,
        expiresAt: json['expires_at'] != null
            ? DateTime.parse(json['expires_at'] as String)
            : json['expires_in'] != null
            ? DateTime.now().add(Duration(seconds: json['expires_in'] as int))
            : null,
      );

  /// Convert login request to JSON
  static Map<String, dynamic> loginRequestToJson(
    String identifier,
    String password,
  ) {
    final requestBody = <String, String>{'password': password};

    if (identifier.contains('@')) {
      requestBody['email'] = identifier;
    } else if (identifier.startsWith('+')) {
      requestBody['phone'] = identifier;
    } else {
      requestBody['username'] = identifier;
    }

    return requestBody;
  }

  /// Convert register request to JSON
  static Map<String, dynamic> registerRequestToJson(
    String name,
    String email,
    String password, {
    String? username,
    String? phone,
  }) {
    final nameParts = name.split(' ');
    final requestBody = <String, dynamic>{
      'first_name': nameParts.first,
      'last_name': nameParts.length > 1 ? nameParts.skip(1).join(' ') : '',
      'email': email,
      'password': password,
    };

    if (username != null && username.isNotEmpty) {
      requestBody['username'] = username;
    }

    if (phone != null && phone.isNotEmpty) {
      requestBody['phone'] = phone;
    }

    return requestBody;
  }

  /// Convert change password request to JSON
  static Map<String, dynamic> changePasswordRequestToJson(
    String oldPassword,
    String newPassword,
  ) => {'old_password': oldPassword, 'new_password': newPassword};

  /// Convert password reset request to JSON
  static Map<String, dynamic> passwordResetRequestToJson(String email) => {
    'email': email,
  };
}
