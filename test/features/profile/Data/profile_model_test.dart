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

  test('_readCount parses doubles and strings', () {
    final model1 = ProfileModel.fromJson({
      'id': 'u1',
      'display_name': 'User',
      'followers_count': 3.7,
      'following_count': '5',
    });

    expect(model1.followersCount, 3);
    expect(model1.followingCount, 5);
  });

  test('_readCount falls back to secondary key', () {
    final model = ProfileModel.fromJson({
      'id': 'u1',
      'display_name': 'User',
      'followersCount': 10,
      'followingCount': 20,
    });

    expect(model.followersCount, 10);
    expect(model.followingCount, 20);
  });

  test('_readCount treats list length as count', () {
    final model = ProfileModel.fromJson({
      'id': 'u1',
      'display_name': 'User',
      'followers_count': [1, 2, 3, 4],
      'following_count': ['a', 'b'],
    });

    expect(model.followersCount, 4);
    expect(model.followingCount, 2);
  });

  test('fromJson maps all social URLs with fallback keys', () {
    final model = ProfileModel.fromJson({
      'id': 'u1',
      'display_name': 'User',
      'instagramUrl': 'ig-url',
      'facebookUrl': 'fb-url',
      'githubUrl': 'gh-url',
    });

    expect(model.instagramUrl, 'ig-url');
    expect(model.facebookUrl, 'fb-url');
    expect(model.githubUrl, 'gh-url');
  });
}
