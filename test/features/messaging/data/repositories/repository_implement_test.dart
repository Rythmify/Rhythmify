import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/messaging/data/datasources/datasource_interface.dart';
import 'package:rythmify/features/messaging/data/models/conversation_model.dart';
import 'package:rythmify/features/messaging/data/models/message_model.dart';
import 'package:rythmify/features/messaging/data/models/potential_conversation_model.dart';
import 'package:rythmify/features/messaging/data/models/sent_message_request_model.dart';
import 'package:rythmify/features/messaging/data/models/shared_embed_model.dart';
import 'package:rythmify/features/messaging/data/repositories/repository_implement.dart';

/// Mock for [DatasourceInterface] used to isolate [RepositoryImplement] under test.
class MockDatasourceInterface extends Mock implements DatasourceInterface {}

/// Tests for [RepositoryImplement].
///
/// Each group verifies that the repository delegates the correct parameters to
/// [DatasourceInterface] without adding any logic of its own, and that the
/// [SentMessageRequestModel] is constructed correctly from raw domain arguments.
void main() {
  late RepositoryImplement repo;
  late MockDatasourceInterface mockDatasource;

  final tDate = DateTime(2024, 6, 1, 12, 0, 0);

  final tConversationModel = ConversationModel(
    conversationId: 'conv-1',
    participantId: 'user-2',
    participantName: 'Alice',
    lastMessagePreview: 'Hey',
    lastMessageDate: tDate,
    unReadCount: 0,
  );

  final tMessageModel = MessageModel(
    messageId: 'msg-1',
    conversationId: 'conv-1',
    senderId: 'user-1',
    body: 'Hello',
    isRead: false,
    createdAt: tDate,
  );

  final tPotentialModel = PotentialConversationModel(
    participantId: 'user-3',
    participantName: 'Bob',
  );

  final tSharedEmbedModel = SharedEmbedModel(
    embedId: 'track-1',
    embedType: 'track',
    embedName: 'Song',
    artistName: 'Artist',
    thumbnailUrl: 'https://example.com/thumb.png',
  );

  setUp(() {
    mockDatasource = MockDatasourceInterface();
    repo = RepositoryImplement(dataSource: mockDatasource);
    registerFallbackValue(SentMessageRequestModel());
  });

  group('RepositoryImplement', () {
    group('getConversations', () {
      test('delegates to datasource and returns result', () async {
        when(() => mockDatasource.getConversations())
            .thenAnswer((_) async => [tConversationModel]);

        final result = await repo.getConversations();

        expect(result, [tConversationModel]);
        verify(() => mockDatasource.getConversations()).called(1);
      });

      test('returns empty list when datasource returns empty', () async {
        when(() => mockDatasource.getConversations())
            .thenAnswer((_) async => []);

        final result = await repo.getConversations();
        expect(result, isEmpty);
      });
    });

    group('getMessages', () {
      test('delegates with correct conversationId and default offset', () async {
        when(() => mockDatasource.getMessages(
              conversationId: any(named: 'conversationId'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => ([tMessageModel], 1));

        final (messages, total) = await repo.getMessages('conv-1');

        expect(messages, [tMessageModel]);
        expect(total, 1);
        verify(() => mockDatasource.getMessages(
              conversationId: 'conv-1',
              offset: 0,
            )).called(1);
      });

      test('passes offset to datasource', () async {
        when(() => mockDatasource.getMessages(
              conversationId: any(named: 'conversationId'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => ([tMessageModel], 50));

        await repo.getMessages('conv-1', offset: 100);

        verify(() => mockDatasource.getMessages(
              conversationId: 'conv-1',
              offset: 100,
            )).called(1);
      });
    });

    group('startConversation', () {
      test('calls datasource.newConversation with correct args', () async {
        when(() => mockDatasource.newConversation(
              participantId: any(named: 'participantId'),
              body: any(named: 'body'),
              trackId: any(named: 'trackId'),
              playlistId: any(named: 'playlistId'),
            )).thenAnswer((_) async => tConversationModel);

        final result = await repo.startConversation(
          'user-2',
          'Hi',
          'track-1',
          null,
        );

        expect(result, tConversationModel);
        verify(() => mockDatasource.newConversation(
              participantId: 'user-2',
              body: 'Hi',
              trackId: 'track-1',
              playlistId: null,
            )).called(1);
      });

      test('passes null body and embed when not provided', () async {
        when(() => mockDatasource.newConversation(
              participantId: any(named: 'participantId'),
              body: any(named: 'body'),
              trackId: any(named: 'trackId'),
              playlistId: any(named: 'playlistId'),
            )).thenAnswer((_) async => tConversationModel);

        await repo.startConversation('user-2', null, null, null);

        verify(() => mockDatasource.newConversation(
              participantId: 'user-2',
              body: null,
              trackId: null,
              playlistId: null,
            )).called(1);
      });
    });

    group('sendMessage', () {
      test('builds SentMessageRequestModel and delegates to datasource', () async {
        when(() => mockDatasource.sendMessage(
              conversationId: any(named: 'conversationId'),
              requestContent: any(named: 'requestContent'),
            )).thenAnswer((_) async => tMessageModel);

        final result = await repo.sendMessage('conv-1', 'Hello', null, null);

        expect(result, tMessageModel);
        verify(() => mockDatasource.sendMessage(
              conversationId: 'conv-1',
              requestContent: any(named: 'requestContent'),
            )).called(1);
      });

      test('passes embedId and embedType to SentMessageRequestModel', () async {
        SentMessageRequestModel? captured;
        when(() => mockDatasource.sendMessage(
              conversationId: any(named: 'conversationId'),
              requestContent: any(named: 'requestContent'),
            )).thenAnswer((invocation) async {
          captured = invocation.namedArguments[const Symbol('requestContent')]
              as SentMessageRequestModel;
          return tMessageModel;
        });

        await repo.sendMessage('conv-1', null, 'track-123', 'track');

        expect(captured?.embedId, 'track-123');
        expect(captured?.embedType, 'track');
        expect(captured?.body, isNull);
      });
    });

    group('blockUser', () {
      test('delegates userId to datasource.blockUser', () async {
        when(() => mockDatasource.blockUser(userId: any(named: 'userId')))
            .thenAnswer((_) async {});

        await repo.blockUser('user-2');

        verify(() => mockDatasource.blockUser(userId: 'user-2')).called(1);
      });
    });

    group('unBlockUser', () {
      test('delegates userId to datasource.unBlockUser', () async {
        when(() => mockDatasource.unBlockUser(userId: any(named: 'userId')))
            .thenAnswer((_) async {});

        await repo.unBlockUser('user-2');

        verify(() => mockDatasource.unBlockUser(userId: 'user-2')).called(1);
      });
    });

    group('markMessageAsRead', () {
      test('passes messageId and conversationId in correct order', () async {
        when(() => mockDatasource.markMessagesAsRead(
              conversationId: any(named: 'conversationId'),
              messageId: any(named: 'messageId'),
            )).thenAnswer((_) async {});

        await repo.markMessageAsRead('msg-1', 'conv-1');

        verify(() => mockDatasource.markMessagesAsRead(
              conversationId: 'conv-1',
              messageId: 'msg-1',
            )).called(1);
      });
    });

    group('getUnReadCount', () {
      test('delegates to datasource.getUnreadCount and returns value', () async {
        when(() => mockDatasource.getUnreadCount()).thenAnswer((_) async => 5);

        final result = await repo.getUnReadCount();

        expect(result, 5);
        verify(() => mockDatasource.getUnreadCount()).called(1);
      });
    });

    group('getFollowings', () {
      test('delegates myId to datasource and returns result', () async {
        when(() => mockDatasource.getFollowings(any()))
            .thenAnswer((_) async => [tPotentialModel]);

        final result = await repo.getFollowings('my-id');

        expect(result, [tPotentialModel]);
        verify(() => mockDatasource.getFollowings('my-id')).called(1);
      });
    });

    group('getSearchedUsers', () {
      test('delegates query to datasource and returns result', () async {
        when(() => mockDatasource.getSearchedUsers(any()))
            .thenAnswer((_) async => [tPotentialModel]);

        final result = await repo.getSearchedUsers('alice');

        expect(result, [tPotentialModel]);
        verify(() => mockDatasource.getSearchedUsers('alice')).called(1);
      });
    });

    group('isBlocked', () {
      test('returns true when datasource returns true', () async {
        when(() => mockDatasource.isBlocked(any()))
            .thenAnswer((_) async => true);

        expect(await repo.isBlocked('user-2'), true);
        verify(() => mockDatasource.isBlocked('user-2')).called(1);
      });

      test('returns false when datasource returns false', () async {
        when(() => mockDatasource.isBlocked(any()))
            .thenAnswer((_) async => false);

        expect(await repo.isBlocked('user-3'), false);
      });
    });

    group('isBlockedBy', () {
      test('returns bool from datasource', () async {
        when(() => mockDatasource.isBlockedBy(any()))
            .thenAnswer((_) async => true);

        expect(await repo.isBlockedBy('user-2'), true);
        verify(() => mockDatasource.isBlockedBy('user-2')).called(1);
      });
    });

    group('getLikedEmbeds', () {
      test('delegates to datasource.getEmbeds with userId and embedType', () async {
        when(() => mockDatasource.getEmbeds(any(), any()))
            .thenAnswer((_) async => [tSharedEmbedModel]);

        final result = await repo.getLikedEmbeds('user-1', 'track');

        expect(result, [tSharedEmbedModel]);
        verify(() => mockDatasource.getEmbeds('user-1', 'track')).called(1);
      });
    });

    group('getTrack', () {
      test('delegates to datasource.getTrackDetails', () async {
        when(() => mockDatasource.getTrackDetails(any()))
            .thenAnswer((_) async => tSharedEmbedModel);

        final result = await repo.getTrack('track-1');

        expect(result, tSharedEmbedModel);
        verify(() => mockDatasource.getTrackDetails('track-1')).called(1);
      });
    });

    group('getPlaylist', () {
      test('delegates to datasource.getPlaylistDetails with id and type', () async {
        when(() => mockDatasource.getPlaylistDetails(any(), any()))
            .thenAnswer((_) async => tSharedEmbedModel);

        final result = await repo.getPlaylist('pl-1', 'playlist');

        expect(result, tSharedEmbedModel);
        verify(() => mockDatasource.getPlaylistDetails('pl-1', 'playlist'))
            .called(1);
      });
    });

    group('ensureConversation', () {
      test('delegates participantId to datasource', () async {
        when(() => mockDatasource.ensureConversation(
              participantId: any(named: 'participantId'),
            )).thenAnswer((_) async => tConversationModel);

        final result = await repo.ensureConversation('user-2');

        expect(result, tConversationModel);
        verify(() => mockDatasource.ensureConversation(
              participantId: 'user-2',
            )).called(1);
      });
    });
  });
}
