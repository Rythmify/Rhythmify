import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final bool isEmailVerified;
  final String? token;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.isEmailVerified,
    this.token,
  });

  @override
  List<Object?> get props => [id, email, displayName, isEmailVerified, token];
}