import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/profile/data/models/profile_model.dart';

void main() {
  test('fromJson maps avatar/cover fallbacks and defaults', () {
    final model = ProfileModel.fromJson({
      'id': 'u1',
      'display_name': 'User',
      'profile_picture': 'avatar',
      'cover_photo': 'cover',
    });

    expect(model.avatarUrl, 'avatar');
    expect(model.coverUrl, 'cover');
    expect(model.followersCount, 0);
    expect(model.isFollowing, false);
  });

  test('toJson contains expected keys', () {
    const model = ProfileModel(
      id: 'u1',
      displayName: 'User',
      followersCount: 1,
      followingCount: 2,
      tracksCount: 3,
      isFollowing: true,
      isVerified: true,
    );

    final json = model.toJson();
    expect(json['id'], 'u1');
    expect(json['display_name'], 'User');
    expect(json['is_following'], true);
    expect(json['is_verified'], true);
  });

  test('fromJson does not accumulate follower/following counts', () {
    final model = ProfileModel.fromJson({
      'id': 'u1',
      'display_name': 'User',
      'followers_count': 3,
      'following_count': 2,
      // Extra payload keys that must not be added to counters.
      'followers': [1, 2, 3],
      'following': [1, 2],
      'follower_count': 99,
      'following_count_total': 99,
    });

    expect(model.followersCount, 3);
    expect(model.followingCount, 2);
  });
}
