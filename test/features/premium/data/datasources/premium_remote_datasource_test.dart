import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/premium/data/datasources/premium_remote_datasource.dart';
import 'package:rythmify/features/premium/domain/entities/subscription_plan.dart';
import 'package:rythmify/features/premium/domain/entities/user_subscription.dart';
import 'package:rythmify/features/premium/domain/entities/checkout_session.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late PremiumRemoteDatasource datasource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    datasource = PremiumRemoteDatasource(mockDio);
  });

  final tPlanJson = {
    'subscription_plan_id': 'plan-123',
    'name': 'premium',
    'price': '9.99',
    'duration_days': 30,
    'track_limit': null,
    'playlist_limit': null,
  };

  final tUserSubscriptionJson = {
    'user_subscription_id': 'sub-456',
    'user_id': 'user-789',
    'status': 'active',
    'start_date': '2024-01-01',
    'end_date': '2024-02-01',
    'auto_renew': true,
    'plan': tPlanJson,
  };

  final tCheckoutSessionJson = {
    'transaction_id': 'trans-000',
    'user_subscription_id': 'sub-456',
    'checkout_status': 'pending',
    'payment_method': 'stripe',
    'payment_url': 'https://stripe.com/pay',
    'plan': tPlanJson,
  };

  group('PremiumRemoteDatasource', () {
    group('fetchPlans', () {
      test('should return list of SubscriptionPlan on success', () async {
        // Arrange
        when(() => mockDio.get('/subscriptions/plans')).thenAnswer(
          (_) async => Response(
            data: {
              'data': {
                'items': [tPlanJson],
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/subscriptions/plans'),
          ),
        );

        // Act
        final result = await datasource.fetchPlans();

        // Assert
        expect(result, isA<List<SubscriptionPlan>>());
        expect(result.length, 1);
        expect(result.first.planId, 'plan-123');
      });
    });

    group('fetchMySubscription', () {
      test('should return UserSubscription on success', () async {
        // Arrange
        when(() => mockDio.get('/subscriptions/me')).thenAnswer(
          (_) async => Response(
            data: {'data': tUserSubscriptionJson},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/subscriptions/me'),
          ),
        );

        // Act
        final result = await datasource.fetchMySubscription();

        // Assert
        expect(result, isA<UserSubscription>());
        expect(result.subscriptionId, 'sub-456');
      });
    });

    group('startCheckout', () {
      test('should return CheckoutSession on success', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            data: {'data': tCheckoutSessionJson},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/subscriptions/checkout'),
          ),
        );

        // Act
        final result = await datasource.startCheckout('plan-123');

        // Assert
        expect(result, isA<CheckoutSession>());
        expect(result.transactionId, 'trans-000');
        verify(
          () => mockDio.post(
            '/subscriptions/checkout',
            data: {'subscription_plan_id': 'plan-123'},
          ),
        ).called(1);
      });

      test('should parse planId to int if possible', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            data: {'data': tCheckoutSessionJson},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/subscriptions/checkout'),
          ),
        );

        // Act
        await datasource.startCheckout('123');

        // Assert
        verify(
          () => mockDio.post(
            '/subscriptions/checkout',
            data: {'subscription_plan_id': 123},
          ),
        ).called(1);
      });
    });

    group('confirmMockPayment', () {
      test('should call confirm endpoint', () async {
        // Arrange
        when(() => mockDio.post(any())).thenAnswer(
          (_) async => Response(
            data: {},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/subscriptions/mock-confirm/trans-000',
            ),
          ),
        );

        // Act
        await datasource.confirmMockPayment('trans-000');

        // Assert
        verify(
          () => mockDio.post('/subscriptions/mock-confirm/trans-000'),
        ).called(1);
      });
    });

    group('cancelSubscription', () {
      test('should call cancel endpoint', () async {
        // Arrange
        when(() => mockDio.post('/subscriptions/cancel')).thenAnswer(
          (_) async => Response(
            data: {},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/subscriptions/cancel'),
          ),
        );

        // Act
        await datasource.cancelSubscription();

        // Assert
        verify(() => mockDio.post('/subscriptions/cancel')).called(1);
      });
    });

    group('fetchPendingTransactionId', () {
      test('should return transactionId if found', () async {
        // Arrange
        when(
          () => mockDio.get(
            '/subscriptions/transactions',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'data': [
                {'transaction_id': 'trans-pending'},
              ],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/subscriptions/transactions'),
          ),
        );

        // Act
        final result = await datasource.fetchPendingTransactionId('plan-123');

        // Assert
        expect(result, 'trans-pending');
      });

      test('should return null if no transactions found', () async {
        // Arrange
        when(
          () => mockDio.get(
            '/subscriptions/transactions',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {'data': []},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/subscriptions/transactions'),
          ),
        );

        // Act
        final result = await datasource.fetchPendingTransactionId('plan-123');

        // Assert
        expect(result, isNull);
      });
    });
  });
}
