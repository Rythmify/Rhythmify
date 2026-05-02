import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/messaging/data/datasources/api_endpoints.dart';

void main() {
  group('ApiEndPoints', () {
    test('getConversations is correct', () {
      expect(ApiEndPoints.getConversations, '/messages/conversations');
    });

    test('getConversation returns correct path', () {
      expect(ApiEndPoints.getConversation('c1'), '/messages/conversations/c1');
    });

    test('getMessages returns path with offset and limit', () {
      expect(
        ApiEndPoints.getMessages('c1', offset: 5, limit: 20),
        '/messages/conversations/c1?offset=5&limit=20',
      );
    });

    test('getMessages uses defaults offset=0 limit=100', () {
      expect(
        ApiEndPoints.getMessages('c1'),
        '/messages/conversations/c1?offset=0&limit=100',
      );
    });

    test('sendMessage returns correct path', () {
      expect(
        ApiEndPoints.sendMessage('c1'),
        '/messages/conversations/c1/messages',
      );
    });

    test('newConversation is correct', () {
      expect(ApiEndPoints.newConversation, '/messages/new');
    });

    test('ensureConversation is correct', () {
      expect(ApiEndPoints.ensureConversation, '/messages/conversations/ensure');
    });

    test('getUnreadCount is correct', () {
      expect(ApiEndPoints.getUnreadCount, '/messages/unread-count');
    });

    test('blockUser returns correct path', () {
      expect(ApiEndPoints.blockUser('u1'), '/users/u1/block');
    });

    test('unBlockUser returns correct path', () {
      expect(ApiEndPoints.unBlockUser('u1'), '/users/u1/block');
    });

    test('markMessagesAsRead returns correct path', () {
      expect(
        ApiEndPoints.markMessagesAsRead('c1', 'm1'),
        '/messages/conversations/c1/messages/m1/read',
      );
    });

    test('getFollowings returns correct path', () {
      expect(ApiEndPoints.getFollowings(), '/users/me/following');
    });

    test('getSearchedUsers returns correct path', () {
      expect(
        ApiEndPoints.getSearchedUsers('ali'),
        '/search?q=ali&type=users',
      );
    });

    test('isBlocked returns correct path', () {
      expect(ApiEndPoints.isBlocked('u1'), '/users/u1/follow-status');
    });

    test('getTrackDetails returns correct path', () {
      expect(ApiEndPoints.getTrackDetails('t1'), '/tracks/t1');
    });

    test('getPlaylistDetails returns correct path', () {
      expect(ApiEndPoints.getPlaylistDetails('p1'), '/playlists/p1');
    });

    test('getMyLikedTracks returns correct path', () {
      expect(ApiEndPoints.getMyLikedTracks(), '/me/liked-tracks');
    });

    test('getMyLikedPlaylists returns correct path', () {
      expect(ApiEndPoints.getMyLikedPlaylists(), '/me/liked-playlists');
    });

    test('getMyLikedAlbums returns correct path', () {
      expect(ApiEndPoints.getMyLikedAlbums(), '/me/liked-albums');
    });
  });
}
