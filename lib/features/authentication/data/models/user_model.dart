import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.avatarUrl,
    required super.isEmailVerified,
    super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'is_email_verified': isEmailVerified,
      'token': token,
    };
  }

  factory UserModel.fromSupabase(Map<String, dynamic> data, {String? token}) {
    return UserModel(
      id: data['id'] as String,
      email: data['email'] as String,
      displayName: data['display_name'] as String? ?? '',
      avatarUrl: data['avatar_url'] as String?,
      isEmailVerified: data['email_confirmed_at'] != null,
      token: token,
    );
  }
}
