import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/messaging/data/datasources/data_sources_sockets.dart';
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/send_message_notifier.dart';
import 'package:rythmify/features/messaging/presentation/providers/send_message_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/socket_provider.dart';

/// Mock for [MessagingRepository] injected via [repositoryprovider] override.
class MockMessagingRepository extends Mock implements MessagingRepository {}

/// Mock for [DataSourcesSockets] injected via [socketProvider] override.
class MockDataSourcesSockets extends Mock implements DataSourcesSockets {}

/// Tests for [SendMessageNotifier].
///
/// Covers the two sending paths: sending within an existing conversation
/// (delegates to [SendMessageUsecase], emits via socket, invalidates inbox)
/// and starting a new conversation (delegates to [StartConversationUsecase],
/// routes embedId to trackId or playlistId based on embedType).
/// Also tests [ensureConversation] state management.
void main() {
  late MockMessagingRepository mockRepo;
  late MockDataSourcesSockets mockSocket;

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

  setUp(() {
    mockRepo = MockMessagingRepository();
    mockSocket = MockDataSourcesSockets();

    when(() => mockSocket.sendMessage(any(), any())).thenReturn(null);

    when(
      () => mockRepo.getMessages(any(), offset: any(named: 'offset')),
    ).thenAnswer((_) async => ([tMessage], 1));

    when(
      () => mockRepo.getConversations(),
    ).thenAnswer((_) async => [tConversation]);
  });

  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [
        repositoryprovider.overrideWithValue(mockRepo),
        socketProvider.overrideWithValue(mockSocket),
      ],
    );
  }

  group('SendMessageNotifier', () {
    test('initial state is false (not loading)', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(container.read(sendMessageProvider), false);
    });

    group('sendMessage — with existing conversationId', () {
      test('calls repo.sendMessage and returns null', () async {
        when(
          () => mockRepo.sendMessage(any(), any(), any(), any()),
        ).thenAnswer((_) async => tMessage);

        final container = buildContainer();
        addTearDown(container.dispose);

        final result = await container
            .read(sendMessageProvider.notifier)
            .sendMessage(conversationId: 'conv-1', body: 'Hello');

        expect(result, isNull);
        verify(
          () => mockRepo.sendMessage('conv-1', 'Hello', null, null),
        ).called(1);
      });

      test('state returns to false after completion', () async {
        when(
          () => mockRepo.sendMessage(any(), any(), any(), any()),
        ).thenAnswer((_) async => tMessage);

        final container = buildContainer();
        addTearDown(container.dispose);

        await container
            .read(sendMessageProvider.notifier)
            .sendMessage(conversationId: 'conv-1', body: 'Hello');

        expect(container.read(sendMessageProvider), false);
      });

      test('calls socket.sendMessage with conversation data', () async {
        when(
          () => mockRepo.sendMessage(any(), any(), any(), any()),
        ).thenAnswer((_) async => tMessage);

        final container = buildContainer();
        addTearDown(container.dispose);

        await container
            .read(sendMessageProvider.notifier)
            .sendMessage(conversationId: 'conv-1', body: 'Hello');

        verify(() => mockSocket.sendMessage('conv-1', any())).called(1);
      });

      test('passes embedId and embedType to repo.sendMessage', () async {
        final embedMessage = Message(
          messageId: 'msg-2',
          senderId: 'user-1',
          conversationId: 'conv-1',
          embedId: 'track-1',
          embedType: 'track',
          isRead: false,
          createdAt: tDate,
        );
        when(
          () => mockRepo.sendMessage(any(), any(), any(), any()),
        ).thenAnswer((_) async => embedMessage);

        final container = buildContainer();
        addTearDown(container.dispose);

        await container
            .read(sendMessageProvider.notifier)
            .sendMessage(
              conversationId: 'conv-1',
              embedId: 'track-1',
              embedType: 'track',
            );

        verify(
          () => mockRepo.sendMessage('conv-1', null, 'track-1', 'track'),
        ).called(1);
      });
    });

    group('sendMessage — without conversationId (new conversation)', () {
      test(
        'calls repo.startConversation and returns new conversation',
        () async {
          when(
            () => mockRepo.startConversation(any(), any(), any(), any()),
          ).thenAnswer((_) async => tConversation);

          final container = buildContainer();
          addTearDown(container.dispose);

          final result = await container
              .read(sendMessageProvider.notifier)
              .sendMessage(newParticipantId: 'user-2', body: 'Hello');

          expect(result, tConversation);
          verify(
            () => mockRepo.startConversation('user-2', 'Hello', null, null),
          ).called(1);
        },
      );

      test('routes track embedId to trackId', () async {
        when(
          () => mockRepo.startConversation(any(), any(), any(), any()),
        ).thenAnswer((_) async => tConversation);

        final container = buildContainer();
        addTearDown(container.dispose);

        await container
            .read(sendMessageProvider.notifier)
            .sendMessage(
              newParticipantId: 'user-2',
              embedId: 'track-123',
              embedType: 'track',
            );

        verify(
          () => mockRepo.startConversation('user-2', null, 'track-123', null),
        ).called(1);
      });

      test('routes playlist embedId to playlistId', () async {
        when(
          () => mockRepo.startConversation(any(), any(), any(), any()),
        ).thenAnswer((_) async => tConversation);

        final container = buildContainer();
        addTearDown(container.dispose);

        await container
            .read(sendMessageProvider.notifier)
            .sendMessage(
              newParticipantId: 'user-2',
              embedId: 'pl-456',
              embedType: 'playlist',
            );

        verify(
          () => mockRepo.startConversation('user-2', null, null, 'pl-456'),
        ).called(1);
      });

      test(
        'state returns to false after new conversation is created',
        () async {
          when(
            () => mockRepo.startConversation(any(), any(), any(), any()),
          ).thenAnswer((_) async => tConversation);

          final container = buildContainer();
          addTearDown(container.dispose);

          await container
              .read(sendMessageProvider.notifier)
              .sendMessage(newParticipantId: 'user-2');

          expect(container.read(sendMessageProvider), false);
        },
      );
    });

    group('ensureConversation', () {
      test('calls repo.ensureConversation and returns conversation', () async {
        when(
          () => mockRepo.ensureConversation(any()),
        ).thenAnswer((_) async => tConversation);

        final container = buildContainer();
        addTearDown(container.dispose);

        final result = await container
            .read(sendMessageProvider.notifier)
            .ensureConversation('user-2');

        expect(result, tConversation);
        verify(() => mockRepo.ensureConversation('user-2')).called(1);
      });

      test('state returns to false after completion', () async {
        when(
          () => mockRepo.ensureConversation(any()),
        ).thenAnswer((_) async => tConversation);

        final container = buildContainer();
        addTearDown(container.dispose);

        await container
            .read(sendMessageProvider.notifier)
            .ensureConversation('user-2');

        expect(container.read(sendMessageProvider), false);
      });
    });

    test('is a StateNotifier<bool>', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(
        container.read(sendMessageProvider.notifier),
        isA<SendMessageNotifier>(),
      );
    });
  });
}
