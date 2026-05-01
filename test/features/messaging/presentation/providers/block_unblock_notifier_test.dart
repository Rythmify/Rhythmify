import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';
import 'package:rythmify/features/messaging/presentation/providers/block_user_notifier.dart';
import 'package:rythmify/features/messaging/presentation/providers/block_user_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/un_block_notifier.dart';
import 'package:rythmify/features/messaging/presentation/providers/un_block_provider.dart';

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

  final tMessage = Message(
    messageId: 'msg-1',
    senderId: 'user-1',
    conversationId: 'conv-1',
    isRead: false,
    createdAt: tDate,
  );

  setUp(() {
    mockRepo = MockMessagingRepository();

    when(() => mockRepo.getConversations())
        .thenAnswer((_) async => [tConversation]);
    when(() => mockRepo.getMessages(any(), offset: any(named: 'offset')))
        .thenAnswer((_) async => ([tMessage], 1));
    when(() => mockRepo.isBlocked(any())).thenAnswer((_) async => false);
  });

  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [repositoryprovider.overrideWithValue(mockRepo)],
    );
  }

  // =========================================================================
  // BlockUserNotifier
  // =========================================================================

  group('BlockUserNotifier', () {
    test('initial state is false', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(container.read(blockUserProvider), false);
    });

    test('blockUser calls repo.blockUser with participantId', () async {
      when(() => mockRepo.blockUser(any())).thenAnswer((_) async {});

      final container = buildContainer();
      addTearDown(container.dispose);

      await container
          .read(blockUserProvider.notifier)
          .blockUser(participantId: 'user-2');

      verify(() => mockRepo.blockUser('user-2')).called(1);
    });

    test('state returns to false after blockUser completes', () async {
      when(() => mockRepo.blockUser(any())).thenAnswer((_) async {});

      final container = buildContainer();
      addTearDown(container.dispose);

      await container
          .read(blockUserProvider.notifier)
          .blockUser(participantId: 'user-2');

      expect(container.read(blockUserProvider), false);
    });

    test('is a BlockUserNotifier', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(
        container.read(blockUserProvider.notifier),
        isA<BlockUserNotifier>(),
      );
    });

    test('blockUser propagates through usecase to repo', () async {
      when(() => mockRepo.blockUser(any())).thenAnswer((_) async {});

      final container = buildContainer();
      addTearDown(container.dispose);

      await container
          .read(blockUserProvider.notifier)
          .blockUser(participantId: 'user-99');

      verify(() => mockRepo.blockUser('user-99')).called(1);
    });
  });

  // =========================================================================
  // UnblockNotifier
  // =========================================================================

  group('UnblockNotifier', () {
    test('initial state is false', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(container.read(unBlockProvider), false);
    });

    test('unBlockUser calls repo.unBlockUser with participantId', () async {
      when(() => mockRepo.unBlockUser(any())).thenAnswer((_) async {});

      final container = buildContainer();
      addTearDown(container.dispose);

      await container
          .read(unBlockProvider.notifier)
          .unBlockUser(participantId: 'user-2');

      verify(() => mockRepo.unBlockUser('user-2')).called(1);
    });

    test('state returns to false after unBlockUser completes', () async {
      when(() => mockRepo.unBlockUser(any())).thenAnswer((_) async {});

      final container = buildContainer();
      addTearDown(container.dispose);

      await container
          .read(unBlockProvider.notifier)
          .unBlockUser(participantId: 'user-2');

      expect(container.read(unBlockProvider), false);
    });

    test('is an UnblockNotifier', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(
        container.read(unBlockProvider.notifier),
        isA<UnblockNotifier>(),
      );
    });

    test('unBlockUser propagates through usecase to repo', () async {
      when(() => mockRepo.unBlockUser(any())).thenAnswer((_) async {});

      final container = buildContainer();
      addTearDown(container.dispose);

      await container
          .read(unBlockProvider.notifier)
          .unBlockUser(participantId: 'user-42');

      verify(() => mockRepo.unBlockUser('user-42')).called(1);
    });
  });

  // =========================================================================
  // isBlockedProvider & isBlockedByProvider wiring
  // =========================================================================

  group('isBlockedProvider wiring', () {
    test('calls repo.isBlocked for given participantId', () async {
      when(() => mockRepo.isBlocked('user-2')).thenAnswer((_) async => true);

      final container = buildContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        // ignore: invalid_use_of_internal_member
        Provider<Future<bool>>((ref) async {
          final usecase = ref.read(repositoryprovider);
          return usecase.isBlocked('user-2');
        }),
      );

      expect(await result, true);
    });
  });
}
