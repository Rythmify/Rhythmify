import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/authentication/data/models/user_model.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_state.dart';
import 'package:rythmify/features/premium/data/datasources/premium_remote_datasource.dart';
import 'package:rythmify/features/premium/domain/entities/checkout_session.dart';
import 'package:rythmify/features/premium/domain/entities/subscription_plan.dart';
import 'package:rythmify/features/premium/domain/entities/user_subscription.dart';
import 'package:rythmify/features/premium/presentation/providers/premium_provider.dart';
import 'package:rythmify/features/profile/domain/entities/profile_entity.dart';
import 'package:rythmify/features/profile/presentation/providers/profile_provider.dart';
import 'package:rythmify/features/profile/presentation/providers/profile_state.dart';

// ============ Mock Classes ============

class MockPremiumRemoteDatasource extends Mock
    implements PremiumRemoteDatasource {}

class MockAuthNotifier extends AuthNotifier {
  final AuthState _initialState;
  MockAuthNotifier(this._initialState);
  @override
  AuthState build() => _initialState;
  void updateState(AuthState newState) => state = newState;
}

class MockProfileNotifier extends ProfileNotifier {
  final ProfileState _initialState;
  MockProfileNotifier(this._initialState);
  @override
  ProfileState build() => _initialState;
  @override
  Future<void> loadProfile({required String userId}) async {}
}

class MockPremiumNotifier extends PremiumNotifier {
  final PremiumState _state;
  MockPremiumNotifier(this._state);

  @override
  PremiumState build() => _state;
}

// ============ Test Fixtures ============

const tPlan = SubscriptionPlan(
  planId: 'plan-123',
  name: 'premium',
  price: '9.99',
  durationDays: 30,
  trackLimit: null,
  playlistLimit: null,
);

const tUserSubscription = UserSubscription(
  subscriptionId: 'sub-456',
  userId: 'user-789',
  status: 'active',
  startDate: '2024-01-01',
  endDate: '2024-02-01',
  autoRenew: true,
  plan: tPlan,
);

const tCheckoutSession = CheckoutSession(
  transactionId: 'trans-000',
  subscriptionId: 'sub-456',
  checkoutStatus: 'pending',
  paymentMethod: 'stripe',
  paymentUrl: 'https://stripe.com/pay',
  plan: tPlan,
);

const tUser = UserModel(
  id: 'user-789',
  email: 'test@test.com',
  displayName: 'Test User',
  isEmailVerified: true,
);

final tProfile = ProfileEntity(
  id: 'user-789',
  username: 'testuser',
  displayName: 'Test User',
  isUserPremium: false,
  followersCount: 0,
  followingCount: 0,
  tracksCount: 0,
);

void main() {
  late MockPremiumRemoteDatasource mockDatasource;
  late MockAuthNotifier mockAuthNotifier;
  late MockProfileNotifier mockProfileNotifier;

  setUpAll(() {
    registerFallbackValue(const AuthUnauthenticated());
  });

  setUp(() {
    mockDatasource = MockPremiumRemoteDatasource();
    mockAuthNotifier = MockAuthNotifier(const AuthUnauthenticated());
    mockProfileNotifier = MockProfileNotifier(ProfileLoaded(profile: tProfile));

    // Default mocks
    when(() => mockDatasource.fetchPlans()).thenAnswer((_) async => [tPlan]);
    when(
      () => mockDatasource.fetchMySubscription(),
    ).thenAnswer((_) async => tUserSubscription);
  });

  ProviderContainer createContainer({AuthState? authState}) {
    if (authState != null) {
      mockAuthNotifier = MockAuthNotifier(authState);
    }
    final container = ProviderContainer(
      overrides: [
        premiumDatasourceProvider.overrideWithValue(mockDatasource),
        authProvider.overrideWith(() => mockAuthNotifier),
        ownProfileProvider.overrideWith(() => mockProfileNotifier),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<void> waitForInit(ProviderContainer container) async {
    int count = 0;
    while (!container.read(premiumProvider).isInitialized && count < 100) {
      await Future.delayed(const Duration(milliseconds: 10));
      count++;
    }
  }

  group('PremiumProvider', () {
    test('initial state is default PremiumState', () {
      final container = createContainer();
      final state = container.read(premiumProvider);

      expect(state.subscription, isNull);
      expect(state.plans, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.isInitialized, isFalse);
    });

    test('initializes when authenticated', () async {
      final container = createContainer(authState: AuthAuthenticated(tUser));

      await waitForInit(container);

      final state = container.read(premiumProvider);
      expect(state.isInitialized, isTrue);
      expect(state.plans, [tPlan]);
      expect(state.subscription, tUserSubscription);
    });

    test('clears state on logout', () async {
      final container = createContainer(authState: AuthAuthenticated(tUser));

      await waitForInit(container);

      // Simulate logout
      mockAuthNotifier.updateState(const AuthUnauthenticated());

      final state = container.read(premiumProvider);
      expect(state.subscription, isNull);
      expect(state.plans, isEmpty);
    });

    group('loadPlans', () {
      test('updates state with plans on success', () async {
        final container = createContainer();
        await container.read(premiumProvider.notifier).loadPlans();

        final state = container.read(premiumProvider);
        expect(state.plans, [tPlan]);
        expect(state.isLoading, isFalse);
      });

      test('updates state with error on failure', () async {
        when(
          () => mockDatasource.fetchPlans(),
        ).thenThrow(Exception('Fetch error'));

        final container = createContainer();
        await container.read(premiumProvider.notifier).loadPlans();

        final state = container.read(premiumProvider);
        expect(state.error, contains('Fetch error'));
        expect(state.isLoading, isFalse);
      });
    });

    group('loadMySubscription', () {
      test('updates state with subscription on success', () async {
        final container = createContainer();
        await container.read(premiumProvider.notifier).loadMySubscription();

        final state = container.read(premiumProvider);
        expect(state.subscription, tUserSubscription);
        expect(state.isLoading, isFalse);
      });

      test('clears subscription on 404', () async {
        when(() => mockDatasource.fetchMySubscription()).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 404,
            ),
          ),
        );

        final container = createContainer();
        await container.read(premiumProvider.notifier).loadMySubscription();

        final state = container.read(premiumProvider);
        expect(state.subscription, isNull);
        expect(state.isLoading, isFalse);
      });
    });

    group('checkout', () {
      test('successful checkout flow', () async {
        when(
          () => mockDatasource.startCheckout(any()),
        ).thenAnswer((_) async => tCheckoutSession);
        when(
          () => mockDatasource.confirmMockPayment(any()),
        ).thenAnswer((_) async => {});
        when(
          () => mockDatasource.fetchMySubscription(),
        ).thenAnswer((_) async => tUserSubscription);

        final container = createContainer();
        // Skip auto-init for checkout test to avoid parallel state updates
        await container.read(premiumProvider.notifier).loadPlans();

        await container.read(premiumProvider.notifier).checkout('plan-123');

        final state = container.read(premiumProvider);
        expect(state.checkoutSuccess, isTrue);
        expect(state.isCheckingOut, isFalse);
        verify(() => mockDatasource.startCheckout('plan-123')).called(1);
      });

      test('handles 409 SUBSCRIPTION_ALREADY_ACTIVE', () async {
        when(() => mockDatasource.startCheckout(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 409,
              data: {
                'error': {'code': 'SUBSCRIPTION_ALREADY_ACTIVE'},
              },
            ),
          ),
        );

        final container = createContainer();
        await container.read(premiumProvider.notifier).checkout('plan-123');

        final state = container.read(premiumProvider);
        expect(state.checkoutSuccess, isTrue);
        verify(() => mockDatasource.fetchMySubscription()).called(1);
      });

      test('handles 409 SUBSCRIPTION_CHECKOUT_PENDING', () async {
        when(() => mockDatasource.startCheckout(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 409,
              data: {
                'error': {'code': 'SUBSCRIPTION_CHECKOUT_PENDING'},
              },
            ),
          ),
        );
        when(
          () => mockDatasource.fetchPendingTransactionId(any()),
        ).thenAnswer((_) async => 'pending-trans-123');
        when(
          () => mockDatasource.confirmMockPayment('pending-trans-123'),
        ).thenAnswer((_) async => {});

        final container = createContainer();
        await container.read(premiumProvider.notifier).checkout('plan-123');

        final state = container.read(premiumProvider);
        expect(state.checkoutSuccess, isTrue);
        verify(
          () => mockDatasource.confirmMockPayment('pending-trans-123'),
        ).called(1);
      });
    });

    group('cancel', () {
      test('successful cancellation', () async {
        when(
          () => mockDatasource.cancelSubscription(),
        ).thenAnswer((_) async => {});

        final container = createContainer();
        await container.read(premiumProvider.notifier).cancel();

        verify(() => mockDatasource.cancelSubscription()).called(1);
      });
    });

    group('PremiumState', () {
      test('copyWith works correctly', () {
        const state = PremiumState();
        final updated = state.copyWith(
          isLoading: true,
          error: 'err',
          checkoutSuccess: true,
          isInitialized: true,
        );

        expect(updated.isLoading, isTrue);
        expect(updated.error, 'err');
        expect(updated.checkoutSuccess, isTrue);
        expect(updated.isInitialized, isTrue);
      });

      test('copyWith clearError and clearSubscription works', () {
        final state = PremiumState(
          error: 'err',
          subscription: tUserSubscription,
        );
        final updated = state.copyWith(
          clearError: true,
          clearSubscription: true,
        );

        expect(updated.error, isNull);
        expect(updated.subscription, isNull);
      });

      test('getters endDate and isCanceled work', () {
        final state = PremiumState(subscription: tUserSubscription);
        expect(state.endDate, tUserSubscription.endDate);
        expect(state.isCanceled, isFalse);
      });

      test('isPremium and isFree work', () {
        const freeState = PremiumState();
        final premiumState = PremiumState(subscription: tUserSubscription);

        expect(freeState.isFree, isTrue);
        expect(freeState.isPremium, isFalse);
        expect(premiumState.isPremium, isTrue);
        expect(premiumState.isFree, isFalse);
      });

      test('feature gate getters work', () {
        final premiumState = PremiumState(subscription: tUserSubscription);
        expect(premiumState.canUploadMoreTracks, isTrue);
        expect(premiumState.canCreateMorePlaylists, isTrue);
        expect(premiumState.canDownload, isTrue);
        expect(premiumState.canListenOffline, isTrue);
      });
    });

    group('checkout edge cases', () {
      test('resolves planId when empty', () async {
        when(
          () => mockDatasource.startCheckout(any()),
        ).thenAnswer((_) async => tCheckoutSession);
        when(
          () => mockDatasource.confirmMockPayment(any()),
        ).thenAnswer((_) async => {});

        final container = createContainer();
        // Setup plans in state
        await container.read(premiumProvider.notifier).loadPlans();

        await container.read(premiumProvider.notifier).checkout('');

        verify(() => mockDatasource.startCheckout('plan-123')).called(1);
      });

      test('handles failed pending transaction recovery', () async {
        when(() => mockDatasource.startCheckout(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 409,
              data: {
                'error': {'code': 'SUBSCRIPTION_CHECKOUT_PENDING'},
              },
            ),
          ),
        );
        when(
          () => mockDatasource.fetchPendingTransactionId(any()),
        ).thenAnswer((_) async => null);

        final container = createContainer();
        await container.read(premiumProvider.notifier).checkout('plan-123');

        final state = container.read(premiumProvider);
        expect(state.error, contains('Could not find pending transaction'));
      });
    });

    group('Notifier utility methods', () {
      test('clearError and clearCheckoutSuccess work', () {
        final container = ProviderContainer(
          overrides: [
            premiumProvider.overrideWith(
              () => MockPremiumNotifier(
                const PremiumState(error: 'err', checkoutSuccess: true),
              ),
            ),
          ],
        );

        container.read(premiumProvider.notifier).clearError();
        expect(container.read(premiumProvider).error, isNull);

        container.read(premiumProvider.notifier).clearCheckoutSuccess();
        expect(container.read(premiumProvider).checkoutSuccess, isFalse);
      });
    });

    group('Feature gate providers', () {
      test('canUploadTracksProvider', () {
        final container = ProviderContainer(
          overrides: [isPremiumProvider.overrideWithValue(true)],
        );
        expect(container.read(canUploadTracksProvider), isTrue);
      });

      test('canCreatePlaylistsProvider', () {
        final container = ProviderContainer(
          overrides: [isPremiumProvider.overrideWithValue(true)],
        );
        expect(container.read(canCreatePlaylistsProvider), isTrue);
      });

      test('canDownloadProvider', () {
        final container = ProviderContainer(
          overrides: [isPremiumProvider.overrideWithValue(true)],
        );
        expect(container.read(canDownloadProvider), isTrue);
      });
    });
  });
}
