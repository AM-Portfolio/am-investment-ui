import '../../domain/entities/user.dart';
import '../dtos/user_dtos.dart';

/// Mapper class to convert between User DTOs and domain entities
class UserMapper {
  /// Convert UserResponse DTO to User domain entity
  static User fromDto(UserResponse dto) => User(
    id: dto.id,
    email: dto.email,
    password: '', // Password not included in response for security
    firstName: dto.firstName,
    lastName: dto.lastName,
    phoneNumber: dto.phoneNumber ?? '', // Handle nullable phoneNumber
    roles: [], // Not included in current DTO, could be added
    createdAt: dto.createdAt,
    updatedAt: dto.updatedAt,
  );

  /// Convert User domain entity to UserResponse DTO
  static UserResponse toDto(User user) => UserResponse(
    id: user.id,
    email: user.email,
    firstName: user.firstName,
    lastName: user.lastName,
    phoneNumber: user.phoneNumber,
    createdAt: user.createdAt ?? DateTime.now(),
    updatedAt: user.updatedAt,
  );

  /// Convert UpdateUserRequest DTO to partial User data
  static Map<String, dynamic> fromUpdateRequestDto(UpdateUserRequest dto) {
    final data = <String, dynamic>{};

    if (dto.firstName != null) data['firstName'] = dto.firstName;
    if (dto.lastName != null) data['lastName'] = dto.lastName;
    if (dto.phoneNumber != null) data['phoneNumber'] = dto.phoneNumber;
    if (dto.avatarUrl != null) data['avatarUrl'] = dto.avatarUrl;

    return data;
  }

  /// Create UpdateUserRequest DTO from User domain entity
  static UpdateUserRequest toUpdateRequestDto(User user) => UpdateUserRequest(
    firstName: user.firstName,
    lastName: user.lastName,
    phoneNumber: user.phoneNumber,
  );

  /// Convert API response JSON to User domain entity (bypassing DTO)
  static User fromJson(Map<String, dynamic> json) {
    // Handle test user JSON structure (name, username, phone)
    // or regular user JSON structure (firstName, lastName, userName, phoneNumber)
    var firstName = '';
    var lastName = '';

    if (json.containsKey('name')) {
      // Test user format - split name into firstName/lastName
      final nameParts = json['name']?.toString().split(' ') ?? [];
      firstName = nameParts.isNotEmpty ? nameParts.first : '';
      lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
    } else {
      // Regular user format
      firstName =
          json['firstName'] as String? ?? json['first_name'] as String? ?? '';
      lastName =
          json['lastName'] as String? ?? json['last_name'] as String? ?? '';
    }

    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      password:
          json['password'] as String? ?? '', // Include password for test users
      firstName: firstName,
      lastName: lastName,
      phoneNumber:
          json['phone'] as String? ??
          json['phoneNumber'] as String? ??
          json['phone_number'] as String? ??
          '',
      userName:
          json['username'] as String? ?? json['userName'] as String? ?? '',
      roles: (json['roles'] as List<dynamic>?)?.cast<String>() ?? [],
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert User domain entity to JSON for API requests
  static Map<String, dynamic> toJson(User user) => {
    'id': user.id,
    'email': user.email,
    'firstName': user.firstName,
    'lastName': user.lastName,
    if (user.phoneNumber.isNotEmpty) 'phoneNumber': user.phoneNumber,
    if (user.userName.isNotEmpty) 'userName': user.userName,
    'roles': user.roles,
    'isActive': user.isActive,
    if (user.lastLoginAt != null)
      'lastLoginAt': user.lastLoginAt!.toIso8601String(),
    if (user.createdAt != null) 'createdAt': user.createdAt!.toIso8601String(),
    if (user.updatedAt != null) 'updatedAt': user.updatedAt!.toIso8601String(),
  };
}
