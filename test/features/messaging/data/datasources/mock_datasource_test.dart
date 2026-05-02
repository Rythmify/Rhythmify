import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/messaging/data/datasources/mock_datasource.dart';
import 'package:rythmify/features/messaging/data/models/sent_message_request_model.dart';

void main() {
  late MockDatasourceImplement ds;

  setUp(() {
    ds = MockDatasourceImplement();
  });

  // ── getConversations ──────────────────────────────────────────────────────

  group('getConversations', () {
    test('returns two initial conversations', () async {
      final convs = await ds.getConversations();
      expect(convs.length, 2);
    });

    test('first conversation has correct data', () async {
      final convs = await ds.getConversations();
      expect(convs.first.conversationId, 'c1');
      expect(convs.first.participantId, 'u2');
      expect(convs.first.participantName, 'Ali');
      expect(convs.first.unReadCount, 2);
    });

    test('second conversation is for Mona', () async {
      final convs = await ds.getConversations();
      expect(convs[1].participantName, 'Mona');
      expect(convs[1].unReadCount, 0);
    });

    test('returns a defensive copy so mutations do not affect internal state',
        () async {
      final a = await ds.getConversations();
      a.clear();
      final b = await ds.getConversations();
      expect(b.length, 2);
    });
  });

  // ── getMessages ───────────────────────────────────────────────────────────

  group('getMessages', () {
    test('returns all messages for c1', () async {
      final (msgs, total) = await ds.getMessages(conversationId: 'c1');
      expect(msgs.length, 3);
      expect(total, 3);
    });

    test('returns all messages for c2', () async {
      final (msgs, total) = await ds.getMessages(conversationId: 'c2');
      expect(msgs.length, 1);
      expect(total, 1);
    });

    test('returns empty list for unknown conversation', () async {
      final (msgs, total) = await ds.getMessages(conversationId: 'unknown');
      expect(msgs, isEmpty);
      expect(total, 0);
    });

    test('respects offset parameter', () async {
      final (msgs, total) = await ds.getMessages(conversationId: 'c1', offset: 2);
      expect(msgs.length, 1);
      expect(total, 3);
      expect(msgs.first.messageId, 'm3');
    });

    test('offset beyond total returns empty list', () async {
      final (msgs, total) = await ds.getMessages(conversationId: 'c1', offset: 10);
      expect(msgs, isEmpty);
      expect(total, 3);
    });
  });

  // ── sendMessage ───────────────────────────────────────────────────────────

  group('sendMessage', () {
    test('creates a message with body', () async {
      final req = SentMessageRequestModel(body: 'Hello');
      final msg = await ds.sendMessage(conversationId: 'c1', requestContent: req);
      expect(msg.body, 'Hello');
      expect(msg.conversationId, 'c1');
      expect(msg.senderId, 'current_user');
      expect(msg.isRead, true);
    });

    test('creates a message with embed', () async {
      final req = SentMessageRequestModel(
        body: 'Check this',
        embedType: 'track',
        embedId: 't1',
      );
      final msg = await ds.sendMessage(conversationId: 'c1', requestContent: req);
      expect(msg.embedType, 'track');
      expect(msg.embedId, 't1');
    });

    test('appends the message so next getMessages returns it', () async {
      final req = SentMessageRequestModel(body: 'New msg');
      await ds.sendMessage(conversationId: 'c1', requestContent: req);
      final (msgs, total) = await ds.getMessages(conversationId: 'c1');
      expect(total, 4);
      expect(msgs.last.body, 'New msg');
    });

    test('updates conversation lastMessagePreview', () async {
      final req = SentMessageRequestModel(body: 'Preview update');
      await ds.sendMessage(conversationId: 'c1', requestContent: req);
      final convs = await ds.getConversations();
      final c1 = convs.firstWhere((c) => c.conversationId == 'c1');
      expect(c1.lastMessagePreview, 'Preview update');
    });

    test('sends message with null body updates preview to empty string', () async {
      final req = SentMessageRequestModel(embedType: 'track', embedId: 't1');
      await ds.sendMessage(conversationId: 'c1', requestContent: req);
      final convs = await ds.getConversations();
      final c1 = convs.firstWhere((c) => c.conversationId == 'c1');
      expect(c1.lastMessagePreview, '');
    });

    test('message sent to unknown conversation is stored', () async {
      final req = SentMessageRequestModel(body: 'Test');
      final msg = await ds.sendMessage(
        conversationId: 'unknown_conv',
        requestContent: req,
      );
      expect(msg.conversationId, 'unknown_conv');
      final (msgs, _) = await ds.getMessages(conversationId: 'unknown_conv');
      expect(msgs.length, 1);
    });
  });

  // ── newConversation ───────────────────────────────────────────────────────

  group('newConversation', () {
    test('returns existing conversation when participant already has one', () async {
      final conv = await ds.newConversation(participantId: 'u2');
      expect(conv.conversationId, 'c1');
    });

    test('sends message to existing conversation when body provided', () async {
      await ds.newConversation(participantId: 'u2', body: 'Re-hello');
      final (msgs, _) = await ds.getMessages(conversationId: 'c1');
      expect(msgs.last.body, 'Re-hello');
    });

    test('sends track embed to existing conversation', () async {
      await ds.newConversation(
        participantId: 'u2',
        body: 'check it',
        trackId: 't1',
      );
      final (msgs, _) = await ds.getMessages(conversationId: 'c1');
      expect(msgs.last.embedType, 'track');
      expect(msgs.last.embedId, 't1');
    });

    test('sends playlist embed to existing conversation', () async {
      await ds.newConversation(
        participantId: 'u2',
        body: 'playlist',
        playlistId: 'p1',
      );
      final (msgs, _) = await ds.getMessages(conversationId: 'c1');
      expect(msgs.last.embedType, 'playlist');
      expect(msgs.last.embedId, 'p1');
    });

    test('creates new conversation for unknown participant with body', () async {
      final conv = await ds.newConversation(
        participantId: 'u7',
        body: 'Hi Sara',
      );
      expect(conv.participantId, 'u7');
      expect(conv.participantName, 'Sara');
      expect(conv.lastMessagePreview, 'Hi Sara');
    });

    test('creates new conversation for unknown-user with fallback name', () async {
      final conv = await ds.newConversation(
        participantId: 'unknown_user',
        body: 'test',
      );
      expect(conv.participantName, 'Unknown User');
    });

    test('creates new conversation without body has empty preview', () async {
      final conv = await ds.newConversation(participantId: 'u8');
      expect(conv.lastMessagePreview, '');
      expect(conv.unReadCount, 0);
    });

    test('creates new conversation with track embed only', () async {
      final conv = await ds.newConversation(
        participantId: 'u8',
        body: 'song',
        trackId: 'track-x',
      );
      expect(conv.participantId, 'u8');
      final (msgs, _) = await ds.getMessages(conversationId: conv.conversationId);
      expect(msgs.first.embedType, 'track');
      expect(msgs.first.embedId, 'track-x');
    });

    test('creates new conversation with playlist embed only', () async {
      final conv = await ds.newConversation(
        participantId: 'u6',
        body: 'playlist',
        playlistId: 'pl-x',
      );
      final (msgs, _) = await ds.getMessages(conversationId: conv.conversationId);
      expect(msgs.first.embedType, 'playlist');
      expect(msgs.first.embedId, 'pl-x');
    });

    test('new conversation without body has empty messages list', () async {
      final conv = await ds.newConversation(participantId: 'u5');
      final (msgs, _) = await ds.getMessages(conversationId: conv.conversationId);
      expect(msgs, isEmpty);
    });

    test('returns same conversation on second call for same participant', () async {
      final conv1 = await ds.newConversation(participantId: 'u4', body: 'first');
      final conv2 = await ds.newConversation(participantId: 'u4', body: 'second');
      expect(conv1.participantId, conv2.participantId);
    });
  });

  // ── ensureConversation ────────────────────────────────────────────────────

  group('ensureConversation', () {
    test('returns existing conversation for known participant', () async {
      final conv = await ds.ensureConversation(participantId: 'u2');
      expect(conv.conversationId, 'c1');
    });

    test('creates new conversation for participant without one', () async {
      final conv = await ds.ensureConversation(participantId: 'u7');
      expect(conv.participantId, 'u7');
      expect(conv.participantName, 'Sara');
    });

    test('creates conversation with fallback name for truly unknown user', () async {
      final conv = await ds.ensureConversation(participantId: 'not_in_map');
      expect(conv.participantName, 'Unknown User');
      expect(conv.lastMessagePreview, '');
    });

    test('newly created conversation appears in list', () async {
      await ds.ensureConversation(participantId: 'u4');
      final convs = await ds.getConversations();
      expect(convs.any((c) => c.participantId == 'u4'), isTrue);
    });
  });

  // ── getUnreadCount ────────────────────────────────────────────────────────

  group('getUnreadCount', () {
    test('returns sum of unread counts across all conversations', () async {
      final count = await ds.getUnreadCount();
      expect(count, 2); // c1=2, c2=0
    });

    test('decreases after markMessagesAsRead', () async {
      await ds.markMessagesAsRead(conversationId: 'c1', messageId: 'm1');
      final count = await ds.getUnreadCount();
      expect(count, 0);
    });
  });

  // ── blockUser / unBlockUser / isBlocked ───────────────────────────────────

  group('blockUser', () {
    test('isBlocked returns false before blocking', () async {
      expect(await ds.isBlocked('u3'), isFalse);
    });

    test('isBlocked returns true after blockUser', () async {
      await ds.blockUser(userId: 'u3');
      expect(await ds.isBlocked('u3'), isTrue);
    });

    test('unBlockUser removes from blocked set', () async {
      await ds.blockUser(userId: 'u3');
      await ds.unBlockUser(userId: 'u3');
      expect(await ds.isBlocked('u3'), isFalse);
    });

    test('isBlocked returns false for multiple unblocked users', () async {
      expect(await ds.isBlocked('u4'), isFalse);
      expect(await ds.isBlocked('u5'), isFalse);
    });
  });

  // ── isBlockedBy ───────────────────────────────────────────────────────────

  group('isBlockedBy', () {
    test('returns true for u2 who has blocked current user', () async {
      expect(await ds.isBlockedBy('u2'), isTrue);
    });

    test('returns false for user who has not blocked current user', () async {
      expect(await ds.isBlockedBy('u3'), isFalse);
    });
  });

  // ── markMessagesAsRead ────────────────────────────────────────────────────

  group('markMessagesAsRead', () {
    test('marks all messages in conversation as read', () async {
      await ds.markMessagesAsRead(conversationId: 'c1', messageId: 'm1');
      final (msgs, _) = await ds.getMessages(conversationId: 'c1');
      expect(msgs.every((m) => m.isRead), isTrue);
    });

    test('resets unReadCount to 0 for the conversation', () async {
      await ds.markMessagesAsRead(conversationId: 'c1', messageId: 'm1');
      final convs = await ds.getConversations();
      final c1 = convs.firstWhere((c) => c.conversationId == 'c1');
      expect(c1.unReadCount, 0);
    });

    test('no-ops gracefully for non-existing conversation', () async {
      await ds.markMessagesAsRead(
        conversationId: 'nonexistent',
        messageId: 'mx',
      );
      final convs = await ds.getConversations();
      expect(convs.length, 2);
    });

    test('preserves conversation metadata after mark as read', () async {
      final before = (await ds.getConversations()).firstWhere(
        (c) => c.conversationId == 'c1',
      );
      await ds.markMessagesAsRead(conversationId: 'c1', messageId: 'm1');
      final after = (await ds.getConversations()).firstWhere(
        (c) => c.conversationId == 'c1',
      );
      expect(after.lastMessagePreview, before.lastMessagePreview);
      expect(after.participantName, before.participantName);
    });
  });

  // ── getFollowings ─────────────────────────────────────────────────────────

  group('getFollowings', () {
    test('returns followings for any userId', () async {
      final users = await ds.getFollowings('any_id');
      expect(users.length, 5);
    });

    test('first following is Ali (u2)', () async {
      final users = await ds.getFollowings('me');
      expect(users.first.participantId, 'u2');
      expect(users.first.participantName, 'Ali');
    });

    test('followings include location when available', () async {
      final users = await ds.getFollowings('me');
      final ali = users.firstWhere((u) => u.participantId == 'u2');
      expect(ali.location, 'Cairo');
    });

    test('followings include null location when not set', () async {
      final users = await ds.getFollowings('me');
      final omar = users.firstWhere((u) => u.participantId == 'u4');
      expect(omar.location, isNull);
    });
  });

  // ── getSearchedUsers ──────────────────────────────────────────────────────

  group('getSearchedUsers', () {
    test('returns empty for empty query', () async {
      final users = await ds.getSearchedUsers('');
      expect(users, isEmpty);
    });

    test('returns empty for whitespace-only query', () async {
      final users = await ds.getSearchedUsers('   ');
      expect(users, isEmpty);
    });

    test('returns matching users for valid query', () async {
      final users = await ds.getSearchedUsers('ali');
      expect(users.length, 1);
      expect(users.first.participantName, 'Ali');
    });

    test('search is case-insensitive', () async {
      final users = await ds.getSearchedUsers('ALI');
      expect(users.length, 1);
    });

    test('returns multiple matches when query is broad', () async {
      final users = await ds.getSearchedUsers('a');
      expect(users.length, greaterThan(1));
    });

    test('returns empty for no match', () async {
      final users = await ds.getSearchedUsers('zzznomatch');
      expect(users, isEmpty);
    });
  });

  // ── getEmbeds ─────────────────────────────────────────────────────────────

  group('getEmbeds', () {
    test('returns only tracks when embedType is track', () async {
      final embeds = await ds.getEmbeds('u1', 'track');
      expect(embeds.isNotEmpty, isTrue);
      expect(embeds.every((e) => e.embedType == 'track'), isTrue);
    });

    test('returns only playlists when embedType is playlist', () async {
      final embeds = await ds.getEmbeds('u1', 'playlist');
      expect(embeds.isNotEmpty, isTrue);
      expect(embeds.every((e) => e.embedType == 'playlist'), isTrue);
    });

    test('returns only albums when embedType is album', () async {
      final embeds = await ds.getEmbeds('u1', 'album');
      expect(embeds.isNotEmpty, isTrue);
      expect(embeds.every((e) => e.embedType == 'album'), isTrue);
    });

    test('returns empty for unknown embed type', () async {
      final embeds = await ds.getEmbeds('u1', 'unknown');
      expect(embeds, isEmpty);
    });

    test('track embeds have artist name', () async {
      final embeds = await ds.getEmbeds('u1', 'track');
      expect(embeds.first.artistName, isNotNull);
    });
  });

  // ── getTrackDetails ───────────────────────────────────────────────────────

  group('getTrackDetails', () {
    test('returns correct track for t1', () async {
      final track = await ds.getTrackDetails('t1');
      expect(track.embedId, 't1');
      expect(track.embedType, 'track');
      expect(track.embedName, 'Bahaa Sultan - Ana Ghaltan');
    });

    test('returns correct track for t2', () async {
      final track = await ds.getTrackDetails('t2');
      expect(track.embedId, 't2');
      expect(track.artistName, 'Milan Drew');
    });

    test('throws when track not found', () async {
      expect(
        () => ds.getTrackDetails('nonexistent_track'),
        throwsStateError,
      );
    });
  });

  // ── getPlaylistDetails ────────────────────────────────────────────────────

  group('getPlaylistDetails', () {
    test('returns correct playlist for p1', () async {
      final pl = await ds.getPlaylistDetails('p1', 'playlist');
      expect(pl.embedId, 'p1');
      expect(pl.embedType, 'playlist');
      expect(pl.embedName, 'My Gym Set');
    });

    test('returns correct album for a1', () async {
      final album = await ds.getPlaylistDetails('a1', 'album');
      expect(album.embedId, 'a1');
      expect(album.embedType, 'album');
    });

    test('throws when playlist not found for given type', () async {
      expect(
        () => ds.getPlaylistDetails('nonexistent', 'playlist'),
        throwsStateError,
      );
    });
  });
}
