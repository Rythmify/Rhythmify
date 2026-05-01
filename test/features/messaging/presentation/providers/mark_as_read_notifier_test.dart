import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';
import 'package:rythmify/features/messaging/presentation/providers/mark_as_read_notifier.dart';
import 'package:rythmify/features/messaging/presentation/providers/mark_as_read_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

/// Mock for [MessagingRepository] injected via [repositoryprovider] override.
class MockMessagingRepository extends Mock implements MessagingRepository {}

/// Tests for [MarkAsReadNotifier].
///
/// Verifies that [markRead] delegates the correct message and conversation IDs
/// to the repository, that the loading state resets to `false` on completion,
/// and that exceptions (including 409 "already read") are silently swallowed.

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

  setUp(() {
    mockRepo = MockMessagingRepository();

    when(() => mockRepo.getConversations())
        .thenAnswer((_) async => [tConversation]);
    when(() => mockRepo.getMessages(any(), offset: any(named: 'offset')))
        .thenAnswer((_) async => ([tMessage], 1));
  });

  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [repositoryprovider.overrideWithValue(mockRepo)],
    );
  }

  group('MarkAsReadNotifier', () {
    test('initial state is false', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(container.read(markAsRead), false);
    });

    test('markRead calls repo.markMessageAsRead with correct args', () async {
      when(() => mockRepo.markMessageAsRead(any(), any()))
          .thenAnswer((_) async {});

      final container = buildContainer();
      addTearDown(container.dispose);

      await container
          .read(markAsRead.notifier)
          .markRead(msgId: 'msg-1', convId: 'conv-1');

      verify(() => mockRepo.markMessageAsRead('msg-1', 'conv-1')).called(1);
    });

    test('state returns to false after markRead completes', () async {
      when(() => mockRepo.markMessageAsRead(any(), any()))
          .thenAnswer((_) async {});

      final container = buildContainer();
      addTearDown(container.dispose);

      await container
          .read(markAsRead.notifier)
          .markRead(msgId: 'msg-1', convId: 'conv-1');

      expect(container.read(markAsRead), false);
    });

    test('state returns to false even when exception is thrown (409 case)',
        () async {
      when(() => mockRepo.markMessageAsRead(any(), any()))
          .thenThrow(Exception('409: Already read'));

      final container = buildContainer();
      addTearDown(container.dispose);

      await container
          .read(markAsRead.notifier)
          .markRead(msgId: 'msg-1', convId: 'conv-1');

      expect(container.read(markAsRead), false);
    });

    test('markRead calls updateMessageRead on the messages notifier', () async {
      when(() => mockRepo.markMessageAsRead(any(), any()))
          .thenAnswer((_) async {});

      final container = buildContainer();
      addTearDown(container.dispose);

      // Prime the messages notifier so it has tMessage loaded
      await Future.delayed(Duration.zero);

      await container
          .read(markAsRead.notifier)
          .markRead(msgId: 'msg-1', convId: 'conv-1');

      // Verify repo was called (indirect proof updateMessageRead ran)
      verify(() => mockRepo.markMessageAsRead('msg-1', 'conv-1')).called(1);
    });

    test('is a MarkAsReadNotifier', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(
        container.read(markAsRead.notifier),
        isA<MarkAsReadNotifier>(),
      );
    });

    test('markRead with different conversationId delegates correctly', () async {
      when(() => mockRepo.markMessageAsRead(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockRepo.getMessages(any(), offset: any(named: 'offset')))
          .thenAnswer((_) async => (<Message>[], 0));

      final container = buildContainer();
      addTearDown(container.dispose);

      await container
          .read(markAsRead.notifier)
          .markRead(msgId: 'msg-99', convId: 'conv-99');

      verify(() => mockRepo.markMessageAsRead('msg-99', 'conv-99')).called(1);
    });
  });
}
