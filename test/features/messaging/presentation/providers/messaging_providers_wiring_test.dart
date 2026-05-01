import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';
import 'package:rythmify/features/messaging/presentation/providers/conversations_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/is_blocked_by_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/is_blocked_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

class MockMessagingRepository extends Mock implements MessagingRepository {}

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

  setUp(() {
    mockRepo = MockMessagingRepository();
  });

  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [repositoryprovider.overrideWithValue(mockRepo)],
    );
  }

  group('conversationProvider wiring', () {
    test('executes GetConversationsUsecase and returns conversations', () async {
      when(() => mockRepo.getConversations())
          .thenAnswer((_) async => [tConversation]);

      final container = buildContainer();
      addTearDown(container.dispose);

      final result = await container.read(conversationProvider.future);

      expect(result, [tConversation]);
      verify(() => mockRepo.getConversations()).called(1);
    });

    test('returns empty list when repo has no conversations', () async {
      when(() => mockRepo.getConversations()).thenAnswer((_) async => []);

      final container = buildContainer();
      addTearDown(container.dispose);

      final result = await container.read(conversationProvider.future);

      expect(result, isEmpty);
    });
  });

  group('isBlockedProvider wiring', () {
    test('executes IsBlockedUsecase and returns true when blocked', () async {
      when(() => mockRepo.isBlocked(any())).thenAnswer((_) async => true);

      final container = buildContainer();
      addTearDown(container.dispose);

      final result =
          await container.read(isBlockedProvider('user-2').future);

      expect(result, true);
      verify(() => mockRepo.isBlocked('user-2')).called(1);
    });

    test('returns false when participant is not blocked', () async {
      when(() => mockRepo.isBlocked(any())).thenAnswer((_) async => false);

      final container = buildContainer();
      addTearDown(container.dispose);

      final result =
          await container.read(isBlockedProvider('user-3').future);

      expect(result, false);
    });
  });

  group('isBlockedByProvider wiring', () {
    test('executes IsBlockedByUsecase and returns true when blocked by', () async {
      when(() => mockRepo.isBlockedBy(any())).thenAnswer((_) async => true);

      final container = buildContainer();
      addTearDown(container.dispose);

      final result =
          await container.read(isBlockedByProvider('user-2').future);

      expect(result, true);
      verify(() => mockRepo.isBlockedBy('user-2')).called(1);
    });

    test('returns false when not blocked by participant', () async {
      when(() => mockRepo.isBlockedBy(any())).thenAnswer((_) async => false);

      final container = buildContainer();
      addTearDown(container.dispose);

      final result =
          await container.read(isBlockedByProvider('user-3').future);

      expect(result, false);
    });
  });
}
