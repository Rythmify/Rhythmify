import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/domain/entities/potential_conversation.dart';
import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';
import 'package:rythmify/features/messaging/domain/usecases/block_user_usecase.dart';
import 'package:rythmify/features/messaging/domain/usecases/ensure_conversation_usecase.dart';
import 'package:rythmify/features/messaging/domain/usecases/get_conversations_usecase.dart';
import 'package:rythmify/features/messaging/domain/usecases/get_followings_usecase.dart';
import 'package:rythmify/features/messaging/domain/usecases/get_liked_embeds_usecase.dart';
import 'package:rythmify/features/messaging/domain/usecases/get_messages_usecase.dart';
import 'package:rythmify/features/messaging/domain/usecases/get_playlist_details_usecase.dart';
import 'package:rythmify/features/messaging/domain/usecases/get_searched_users_usecase.dart';
import 'package:rythmify/features/messaging/domain/usecases/get_track_details_usecase.dart';
import 'package:rythmify/features/messaging/domain/usecases/get_unread_count_usecase.dart';
import 'package:rythmify/features/messaging/domain/usecases/is_blocked_by_usecase.dart';
import 'package:rythmify/features/messaging/domain/usecases/is_blocked_usecase.dart';
import 'package:rythmify/features/messaging/domain/usecases/mark_messages_as_read_usecase.dart';
import 'package:rythmify/features/messaging/domain/usecases/send_message_usecase.dart';
import 'package:rythmify/features/messaging/domain/usecases/start_conversation_usecase.dart';
import 'package:rythmify/features/messaging/domain/usecases/unblock_user_usecase.dart';

/// Mock for [MessagingRepository] used to isolate all messaging use case tests.
class MockMessagingRepository extends Mock implements MessagingRepository {}

/// Tests for all messaging use cases.
///
/// Each use case is tested for correct parameter delegation, return value
/// propagation, and exception re-throwing. No business logic is expected inside
/// use cases — they are thin wrappers that call exactly one repository method.
void main() {
  late MockMessagingRepository mockRepo;

  final tDate = DateTime(2024, 6, 1);

  final tConversation = Conversation(
    conversationId: 'conv-1',
    participantId: 'user-2',
    participantName: 'Alice',
    lastMessagePreview: 'Hey',
    lastMessageDate: tDate,
    unReadCount: 0,
  );

  final tMessage = Message(
    messageId: 'msg-1',
    senderId: 'user-1',
    conversationId: 'conv-1',
    body: 'Hello',
    isRead: false,
    createdAt: tDate,
  );

  final tPotential = PotentialConversation(
    participantId: 'user-3',
    participantName: 'Bob',
  );

  final tEmbed = SharedEmbed(
    embedId: 'track-1',
    embedType: 'track',
    embedName: 'Song',
  );

  setUp(() {
    mockRepo = MockMessagingRepository();
  });

  group('GetConversationsUsecase', () {
    test('calls repo.getConversations and returns list', () async {
      when(() => mockRepo.getConversations())
          .thenAnswer((_) async => [tConversation]);

      final result = await GetConversationsUsecase(repo: mockRepo)();

      expect(result, [tConversation]);
      verify(() => mockRepo.getConversations()).called(1);
    });

    test('returns empty list', () async {
      when(() => mockRepo.getConversations()).thenAnswer((_) async => []);

      expect(await GetConversationsUsecase(repo: mockRepo)(), isEmpty);
    });

    test('propagates exceptions from repo', () {
      when(() => mockRepo.getConversations())
          .thenThrow(Exception('Network error'));

      expect(
        () => GetConversationsUsecase(repo: mockRepo)(),
        throwsException,
      );
    });
  });

  group('GetMessagesUsecase', () {
    test('calls repo.getMessages with conversationId and offset', () async {
      when(() => mockRepo.getMessages(any(), offset: any(named: 'offset')))
          .thenAnswer((_) async => ([tMessage], 1));

      final (messages, total) =
          await GetMessagesUsecase(repo: mockRepo)('conv-1', offset: 10);

      expect(messages, [tMessage]);
      expect(total, 1);
      verify(() => mockRepo.getMessages('conv-1', offset: 10)).called(1);
    });

    test('uses default offset=0 when not specified', () async {
      when(() => mockRepo.getMessages(any(), offset: any(named: 'offset')))
          .thenAnswer((_) async => ([tMessage], 1));

      await GetMessagesUsecase(repo: mockRepo)('conv-1');

      verify(() => mockRepo.getMessages('conv-1', offset: 0)).called(1);
    });
  });

  group('SendMessageUsecase', () {
    test('calls repo.sendMessage with all args', () async {
      when(() => mockRepo.sendMessage(any(), any(), any(), any()))
          .thenAnswer((_) async => tMessage);

      final result = await SendMessageUsecase(repo: mockRepo)(
        'conv-1',
        'Hello',
        null,
        null,
      );

      expect(result, tMessage);
      verify(() => mockRepo.sendMessage('conv-1', 'Hello', null, null))
          .called(1);
    });

    test('passes embedId and embedType through', () async {
      when(() => mockRepo.sendMessage(any(), any(), any(), any()))
          .thenAnswer((_) async => tMessage);

      await SendMessageUsecase(repo: mockRepo)(
        'conv-1',
        null,
        'track-1',
        'track',
      );

      verify(() => mockRepo.sendMessage('conv-1', null, 'track-1', 'track'))
          .called(1);
    });
  });

  group('StartConversationUsecase', () {
    test('calls repo.startConversation with all args', () async {
      when(() => mockRepo.startConversation(any(), any(), any(), any()))
          .thenAnswer((_) async => tConversation);

      final result = await StartConversationUsecase(repo: mockRepo)(
        'user-2',
        body: 'Hello',
        trackId: 'track-1',
        playlistId: null,
      );

      expect(result, tConversation);
      verify(() => mockRepo.startConversation('user-2', 'Hello', 'track-1', null))
          .called(1);
    });

    test('passes null optional args', () async {
      when(() => mockRepo.startConversation(any(), any(), any(), any()))
          .thenAnswer((_) async => tConversation);

      await StartConversationUsecase(repo: mockRepo)('user-2');

      verify(() => mockRepo.startConversation('user-2', null, null, null))
          .called(1);
    });
  });

  group('BlockUserUsecase', () {
    test('calls repo.blockUser with participantId', () async {
      when(() => mockRepo.blockUser(any())).thenAnswer((_) async {});

      await BlockUserUsecase(repo: mockRepo)('user-2');

      verify(() => mockRepo.blockUser('user-2')).called(1);
    });

    test('propagates exceptions', () {
      when(() => mockRepo.blockUser(any())).thenThrow(Exception('Error'));

      expect(() => BlockUserUsecase(repo: mockRepo)('user-2'), throwsException);
    });
  });

  group('UnblockUserUsecase', () {
    test('calls repo.unBlockUser with participantId', () async {
      when(() => mockRepo.unBlockUser(any())).thenAnswer((_) async {});

      await UnblockUserUsecase(repo: mockRepo)('user-2');

      verify(() => mockRepo.unBlockUser('user-2')).called(1);
    });
  });

  group('MarkMessagesAsReadUsecase', () {
    test('calls repo.markMessageAsRead with messageId then conversationId', () async {
      when(() => mockRepo.markMessageAsRead(any(), any()))
          .thenAnswer((_) async {});

      await MarkMessagesAsReadUsecase(repo: mockRepo)('msg-1', 'conv-1');

      verify(() => mockRepo.markMessageAsRead('msg-1', 'conv-1')).called(1);
    });

    test('propagates exceptions', () {
      when(() => mockRepo.markMessageAsRead(any(), any()))
          .thenThrow(Exception('Server error'));

      expect(
        () => MarkMessagesAsReadUsecase(repo: mockRepo)('msg-1', 'conv-1'),
        throwsException,
      );
    });
  });

  group('GetUnreadCountUsecase', () {
    test('calls repo.getUnReadCount and returns value', () async {
      when(() => mockRepo.getUnReadCount()).thenAnswer((_) async => 7);

      final result = await GetUnreadCountUsecase(repo: mockRepo)();

      expect(result, 7);
      verify(() => mockRepo.getUnReadCount()).called(1);
    });

    test('returns 0 when no unread messages', () async {
      when(() => mockRepo.getUnReadCount()).thenAnswer((_) async => 0);

      expect(await GetUnreadCountUsecase(repo: mockRepo)(), 0);
    });
  });

  group('GetFollowingsUsecase', () {
    test('calls repo.getFollowings with userId', () async {
      when(() => mockRepo.getFollowings(any()))
          .thenAnswer((_) async => [tPotential]);

      final result = await GetFollowingsUsecase(repo: mockRepo)('my-id');

      expect(result, [tPotential]);
      verify(() => mockRepo.getFollowings('my-id')).called(1);
    });

    test('returns empty list', () async {
      when(() => mockRepo.getFollowings(any())).thenAnswer((_) async => []);

      expect(await GetFollowingsUsecase(repo: mockRepo)('my-id'), isEmpty);
    });
  });

  group('GetSearchedUsersUsecase', () {
    test('calls repo.getSearchedUsers with query', () async {
      when(() => mockRepo.getSearchedUsers(any()))
          .thenAnswer((_) async => [tPotential]);

      final result = await GetSearchedUsersUsecase(repo: mockRepo)('alice');

      expect(result, [tPotential]);
      verify(() => mockRepo.getSearchedUsers('alice')).called(1);
    });
  });

  group('IsBlockedUsecase', () {
    test('returns true when user is blocked', () async {
      when(() => mockRepo.isBlocked(any())).thenAnswer((_) async => true);

      expect(await IsBlockedUsecase(repo: mockRepo)('user-2'), true);
      verify(() => mockRepo.isBlocked('user-2')).called(1);
    });

    test('returns false when user is not blocked', () async {
      when(() => mockRepo.isBlocked(any())).thenAnswer((_) async => false);

      expect(await IsBlockedUsecase(repo: mockRepo)('user-2'), false);
    });
  });

  group('IsBlockedByUsecase', () {
    test('returns true when blocked by participant', () async {
      when(() => mockRepo.isBlockedBy(any())).thenAnswer((_) async => true);

      expect(await IsBlockedByUsecase(repo: mockRepo)('user-2'), true);
      verify(() => mockRepo.isBlockedBy('user-2')).called(1);
    });

    test('returns false when not blocked by participant', () async {
      when(() => mockRepo.isBlockedBy(any())).thenAnswer((_) async => false);

      expect(await IsBlockedByUsecase(repo: mockRepo)('user-2'), false);
    });
  });

  group('GetLikedEmbedsUseCase', () {
    test('calls repo.getLikedEmbeds with userId and embedType', () async {
      when(() => mockRepo.getLikedEmbeds(any(), any()))
          .thenAnswer((_) async => [tEmbed]);

      final result =
          await GetLikedEmbedsUseCase(repo: mockRepo)('user-1', 'track');

      expect(result, [tEmbed]);
      verify(() => mockRepo.getLikedEmbeds('user-1', 'track')).called(1);
    });

    test('returns empty list when no liked embeds', () async {
      when(() => mockRepo.getLikedEmbeds(any(), any()))
          .thenAnswer((_) async => []);

      expect(
        await GetLikedEmbedsUseCase(repo: mockRepo)('user-1', 'playlist'),
        isEmpty,
      );
    });
  });

  group('GetTrackDetailsUsecase', () {
    test('calls repo.getTrack and returns embed', () async {
      when(() => mockRepo.getTrack(any())).thenAnswer((_) async => tEmbed);

      final result = await GetTrackDetailsUsecase(repo: mockRepo)('track-1');

      expect(result, tEmbed);
      verify(() => mockRepo.getTrack('track-1')).called(1);
    });
  });

  group('GetPlaylistDetailsUsecase', () {
    test('calls repo.getPlaylist with id and type', () async {
      when(() => mockRepo.getPlaylist(any(), any()))
          .thenAnswer((_) async => tEmbed);

      final result =
          await GetPlaylistDetailsUsecase(repo: mockRepo)('pl-1', 'playlist');

      expect(result, tEmbed);
      verify(() => mockRepo.getPlaylist('pl-1', 'playlist')).called(1);
    });

    test('passes album type through', () async {
      when(() => mockRepo.getPlaylist(any(), any()))
          .thenAnswer((_) async => tEmbed);

      await GetPlaylistDetailsUsecase(repo: mockRepo)('alb-1', 'album');

      verify(() => mockRepo.getPlaylist('alb-1', 'album')).called(1);
    });
  });

  group('EnsureConversationUsecase', () {
    test('calls repo.ensureConversation and returns conversation', () async {
      when(() => mockRepo.ensureConversation(any()))
          .thenAnswer((_) async => tConversation);

      final result =
          await EnsureConversationUsecase(repo: mockRepo)('user-2');

      expect(result, tConversation);
      verify(() => mockRepo.ensureConversation('user-2')).called(1);
    });

    test('propagates exceptions', () {
      when(() => mockRepo.ensureConversation(any()))
          .thenThrow(Exception('Not found'));

      expect(
        () => EnsureConversationUsecase(repo: mockRepo)('user-99'),
        throwsException,
      );
    });
  });
}
