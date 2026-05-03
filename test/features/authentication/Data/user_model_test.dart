import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/authentication/data/models/user_model.dart';

void main() {
  test('fromJson maps profile_picture/cover_photo fallbacks', () {
    final model = UserModel.fromJson({
      'id': 'u1',
      'email': 'u@test.com',
      'display_name': 'User',
      'profile_picture': 'avatar',
      'cover_photo': 'cover',
      'is_email_verified': true,
      'token': 'jwt',
    });

    expect(model.avatarUrl, 'avatar');
    expect(model.coverUrl, 'cover');
    expect(model.token, 'jwt');
  });

  test('toJson preserves key fields', () {
    const model = UserModel(
      id: 'u1',
      email: 'u@test.com',
      displayName: 'User',
      isEmailVerified: false,
      token: null,
    );

    final json = model.toJson();
    expect(json['id'], 'u1');
    expect(json['display_name'], 'User');
    expect(json['is_email_verified'], false);
  });

  test('fromSupabase sets verification based on email_confirmed_at', () {
    final verified = UserModel.fromSupabase({
      'id': 'u1',
      'email': 'u@test.com',
      'display_name': 'User',
      'email_confirmed_at': '2026-01-01T00:00:00.000Z',
    }, token: 'jwt');

    final unverified = UserModel.fromSupabase({
      'id': 'u1',
      'email': 'u@test.com',
      'display_name': 'User',
      'email_confirmed_at': null,
    });

    expect(verified.isEmailVerified, true);
    expect(verified.token, 'jwt');
    expect(unverified.isEmailVerified, false);
  });
}
