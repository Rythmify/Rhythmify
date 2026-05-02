import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';
import 'package:rythmify/features/messaging/presentation/providers/messages_notifier.dart';

/// Mock for [MessagingRepository] used to stub [getMessages] in notifier tests.
class MockMessagingRepository extends Mock implements MessagingRepository {}

/// Tests for [MessagesState] and [MessagesNotifier].
///
/// Covers [MessagesState.copyWith] immutability, [loadInitial] for both the
/// ≤100 and >100 total-message paths, error state on exception, [loadMore]
/// prepending and [hasMore] updates, [refresh] resetting pagination,
/// [appendMessage] appending to local state, and [updateMessageRead] targeting.
void main() {
  late MockMessagingRepository mockRepo;

  final tDate = DateTime(2024, 6, 1);

  /// Creates a minimal [Message] with the given [id], optionally marking it read.
  Message makeMessage(String id, {bool isRead = false}) => Message(
    messageId: id,
    senderId: 'user-1',
    conversationId: 'conv-1',
    body: 'Message $id',
    isRead: isRead,
    createdAt: tDate,
  );

  setUp(() {
    mockRepo = MockMessagingRepository();
  });

  MessagesNotifier buildNotifier({String convId = 'conv-1'}) {
    return MessagesNotifier(repo: mockRepo, conversationId: convId);
  }

  // =========================================================================
  // MessagesState
  // =========================================================================

  group('MessagesState', () {
    test('has correct default values', () {
      const state = MessagesState();
      expect(state.messages, isEmpty);
      expect(state.isLoading, true);
      expect(state.isLoadingMore, false);
      expect(state.hasMore, false);
      expect(state.error, isNull);
    });

    group('copyWith', () {
      test('updates messages', () {
        const state = MessagesState();
        final m = Message(
          messageId: 'm1',
          senderId: 'u1',
          conversationId: 'c1',
          isRead: false,
          createdAt: DateTime(2024),
        );
        final updated = state.copyWith(messages: [m]);
        expect(updated.messages, [m]);
        expect(updated.isLoading, true);
      });

      test('updates isLoading to false', () {
        const state = MessagesState();
        final updated = state.copyWith(isLoading: false);
        expect(updated.isLoading, false);
      });

      test('updates isLoadingMore to true', () {
        const state = MessagesState();
        final updated = state.copyWith(isLoadingMore: true);
        expect(updated.isLoadingMore, true);
      });

      test('updates hasMore to true', () {
        const state = MessagesState();
        final updated = state.copyWith(hasMore: true);
        expect(updated.hasMore, true);
      });

      test('sets error when provided', () {
        const state = MessagesState();
        final updated = state.copyWith(error: 'something failed');
        expect(updated.error, 'something failed');
      });

      test('clears error when error param is null', () {
        const state = MessagesState(error: 'old error');
        final updated = state.copyWith(isLoading: false);
        expect(updated.error, isNull);
      });

      test('preserves unchanged fields', () {
        const state = MessagesState(
          isLoading: false,
          isLoadingMore: false,
          hasMore: true,
        );
        final updated = state.copyWith(isLoadingMore: true);
        expect(updated.isLoading, false);
        expect(updated.hasMore, true);
      });
    });
  });

  // =========================================================================
  // MessagesNotifier
  // =========================================================================

  group('MessagesNotifier', () {
    group('loadInitial — total <= 100', () {
      test('sets messages, isLoading=false, hasMore=false', () async {
        final messages = [makeMessage('m1'), makeMessage('m2')];
        when(
          () => mockRepo.getMessages(any(), offset: any(named: 'offset')),
        ).thenAnswer((_) async => (messages, 2));

        final notifier = buildNotifier();
        await Future.delayed(Duration.zero);

        expect(notifier.state.isLoading, false);
        expect(notifier.state.messages, messages);
        expect(notifier.state.hasMore, false);
        expect(notifier.state.error, isNull);
      });

      test('works correctly with exactly 100 messages', () async {
        final messages = List.generate(100, (i) => makeMessage('m$i'));
        when(
          () => mockRepo.getMessages(any(), offset: any(named: 'offset')),
        ).thenAnswer((_) async => (messages, 100));

        final notifier = buildNotifier();
        await Future.delayed(Duration.zero);

        expect(notifier.state.messages.length, 100);
        expect(notifier.state.hasMore, false);
      });
    });

    group('loadInitial — total > 100', () {
      test(
        'fetches latest page and sets hasMore=true when latestOffset > 0',
        () async {
          final firstBatch = List.generate(100, (i) => makeMessage('first$i'));
          final latestBatch = List.generate(50, (i) => makeMessage('latest$i'));

          when(
            () => mockRepo.getMessages(any(), offset: 0),
          ).thenAnswer((_) async => (firstBatch, 150));
          when(
            () => mockRepo.getMessages(any(), offset: 50),
          ).thenAnswer((_) async => (latestBatch, 150));

          final notifier = buildNotifier();
          await Future.delayed(Duration.zero);

          expect(notifier.state.messages, latestBatch);
          expect(notifier.state.isLoading, false);
          expect(notifier.state.hasMore, true);
        },
      );

      test(
        'sets hasMore=false when total is exactly 200 after one loadMore',
        () async {
          final firstBatch = List.generate(100, (i) => makeMessage('b1_$i'));
          final latestBatch = List.generate(100, (i) => makeMessage('b2_$i'));

          when(
            () => mockRepo.getMessages(any(), offset: 0),
          ).thenAnswer((_) async => (firstBatch, 200));
          when(
            () => mockRepo.getMessages(any(), offset: 100),
          ).thenAnswer((_) async => (latestBatch, 200));

          final notifier = buildNotifier();
          await Future.delayed(Duration.zero);

          // latestOffset = 200 - 100 = 100, hasMore = (100 > 0) = true
          expect(notifier.state.hasMore, true);

          // After loadMore, olderOffset = max(0, 100-100) = 0, hasMore = false
          when(
            () => mockRepo.getMessages(any(), offset: 0),
          ).thenAnswer((_) async => (firstBatch, 200));

          await notifier.loadMore();

          expect(notifier.state.hasMore, false);
          expect(notifier.state.messages.first.messageId, 'b1_0');
          expect(notifier.state.messages.last.messageId, 'b2_99');
        },
      );
    });

    group('loadInitial — error handling', () {
      test('sets error state and isLoading=false on exception', () async {
        when(
          () => mockRepo.getMessages(any(), offset: any(named: 'offset')),
        ).thenThrow(Exception('Network error'));

        final notifier = buildNotifier();
        await Future.delayed(Duration.zero);

        expect(notifier.state.isLoading, false);
        expect(notifier.state.error, contains('Network error'));
        expect(notifier.state.hasMore, false);
      });

      test('starts with isLoading=true before async resolves', () {
        // Stub getMessages to never complete
        when(
          () => mockRepo.getMessages(any(), offset: any(named: 'offset')),
        ).thenAnswer((_) async {
          await Future.delayed(const Duration(seconds: 10));
          return (<Message>[], 0);
        });

        final notifier = buildNotifier();
        expect(notifier.state.isLoading, true);
      });
    });

    group('loadMore', () {
      test('prepends older messages and updates hasMore', () async {
        final latestBatch = [makeMessage('latest')];
        final olderBatch = [makeMessage('older')];

        when(
          () => mockRepo.getMessages(any(), offset: 0),
        ).thenAnswer((_) async => (latestBatch, 150));
        when(
          () => mockRepo.getMessages(any(), offset: 50),
        ).thenAnswer((_) async => (latestBatch, 150));

        final notifier = buildNotifier();
        await Future.delayed(Duration.zero);
        expect(notifier.state.hasMore, true);

        when(
          () => mockRepo.getMessages(any(), offset: 0),
        ).thenAnswer((_) async => (olderBatch, 150));

        await notifier.loadMore();

        expect(notifier.state.messages.first.messageId, 'older');
        expect(notifier.state.messages.last.messageId, 'latest');
        expect(notifier.state.isLoadingMore, false);
        expect(notifier.state.hasMore, false);
      });

      test('does nothing when hasMore is false', () async {
        when(
          () => mockRepo.getMessages(any(), offset: any(named: 'offset')),
        ).thenAnswer((_) async => ([makeMessage('m1')], 1));

        final notifier = buildNotifier();
        await Future.delayed(Duration.zero);
        expect(notifier.state.hasMore, false);

        clearInteractions(mockRepo);
        await notifier.loadMore();

        verifyNever(
          () => mockRepo.getMessages(any(), offset: any(named: 'offset')),
        );
      });

      test('sets isLoadingMore to false on exception during load', () async {
        when(
          () => mockRepo.getMessages(any(), offset: 0),
        ).thenAnswer((_) async => ([makeMessage('m1')], 150));
        when(
          () => mockRepo.getMessages(any(), offset: 50),
        ).thenAnswer((_) async => ([makeMessage('m2')], 150));

        final notifier = buildNotifier();
        await Future.delayed(Duration.zero);

        when(
          () => mockRepo.getMessages(any(), offset: 0),
        ).thenThrow(Exception('Load failed'));

        await notifier.loadMore();

        expect(notifier.state.isLoadingMore, false);
      });
    });

    group('refresh', () {
      test('re-runs loadInitial and resets to latest page', () async {
        when(
          () => mockRepo.getMessages(any(), offset: any(named: 'offset')),
        ).thenAnswer((_) async => ([makeMessage('m1')], 1));

        final notifier = buildNotifier();
        await Future.delayed(Duration.zero);
        expect(notifier.state.messages.first.messageId, 'm1');

        when(
          () => mockRepo.getMessages(any(), offset: any(named: 'offset')),
        ).thenAnswer((_) async => ([makeMessage('m2')], 1));

        await notifier.refresh();

        expect(notifier.state.messages.first.messageId, 'm2');
      });
    });

    group('appendMessage', () {
      test('appends message to end of current list', () async {
        final m1 = makeMessage('m1');
        final m2 = makeMessage('m2');

        when(
          () => mockRepo.getMessages(any(), offset: any(named: 'offset')),
        ).thenAnswer((_) async => ([m1], 1));

        final notifier = buildNotifier();
        await Future.delayed(Duration.zero);

        notifier.appendMessage(m2);

        expect(notifier.state.messages, [m1, m2]);
      });

      test('appends to empty list', () async {
        when(
          () => mockRepo.getMessages(any(), offset: any(named: 'offset')),
        ).thenAnswer((_) async => (<Message>[], 0));

        final notifier = buildNotifier();
        await Future.delayed(Duration.zero);

        notifier.appendMessage(makeMessage('new'));

        expect(notifier.state.messages.length, 1);
        expect(notifier.state.messages.first.messageId, 'new');
      });
    });

    group('updateMessageRead', () {
      test('marks only the specified message as read', () async {
        final m1 = makeMessage('m1', isRead: false);
        final m2 = makeMessage('m2', isRead: false);
        final m3 = makeMessage('m3', isRead: false);

        when(
          () => mockRepo.getMessages(any(), offset: any(named: 'offset')),
        ).thenAnswer((_) async => ([m1, m2, m3], 3));

        final notifier = buildNotifier();
        await Future.delayed(Duration.zero);

        notifier.updateMessageRead('m2');

        expect(notifier.state.messages[0].isRead, false);
        expect(notifier.state.messages[1].isRead, true);
        expect(notifier.state.messages[2].isRead, false);
      });

      test('does not change anything for non-existing messageId', () async {
        final m1 = makeMessage('m1', isRead: false);

        when(
          () => mockRepo.getMessages(any(), offset: any(named: 'offset')),
        ).thenAnswer((_) async => ([m1], 1));

        final notifier = buildNotifier();
        await Future.delayed(Duration.zero);

        notifier.updateMessageRead('non-existent');

        expect(notifier.state.messages.first.isRead, false);
      });

      test('can mark an already-read message (no-op on isRead)', () async {
        final m1 = makeMessage('m1', isRead: true);

        when(
          () => mockRepo.getMessages(any(), offset: any(named: 'offset')),
        ).thenAnswer((_) async => ([m1], 1));

        final notifier = buildNotifier();
        await Future.delayed(Duration.zero);

        notifier.updateMessageRead('m1');

        expect(notifier.state.messages.first.isRead, true);
      });
    });
  });
}
