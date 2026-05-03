import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/premium/domain/entities/subscription_plan.dart';
import 'package:rythmify/features/premium/domain/entities/user_subscription.dart';
import 'package:rythmify/features/premium/domain/entities/checkout_session.dart';

void main() {
  group('SubscriptionPlan', () {
    final tPlanJson = {
      'subscription_plan_id': 'plan-123',
      'name': 'premium',
      'price': '9.99',
      'duration_days': 30,
      'track_limit': null,
      'playlist_limit': null,
    };

    test('should return valid SubscriptionPlan from JSON', () {
      final result = SubscriptionPlan.fromJson(tPlanJson);
      expect(result.planId, 'plan-123');
      expect(result.name, 'premium');
      expect(result.price, '9.99');
      expect(result.durationDays, 30);
    });

    test('isFree and isPremium should work correctly', () {
      final premium = SubscriptionPlan.fromJson(tPlanJson);
      final free = SubscriptionPlan.fromJson({...tPlanJson, 'name': 'free'});

      expect(premium.isPremium, isTrue);
      expect(premium.isFree, isFalse);
      expect(free.isFree, isTrue);
      expect(free.isPremium, isFalse);
    });

    test(
      'hasUnlimitedTracks and hasUnlimitedPlaylists should work correctly',
      () {
        final unlimited = SubscriptionPlan.fromJson(tPlanJson);
        final limited = SubscriptionPlan.fromJson({
          ...tPlanJson,
          'track_limit': 10,
          'playlist_limit': 5,
        });

        expect(unlimited.hasUnlimitedTracks, isTrue);
        expect(unlimited.hasUnlimitedPlaylists, isTrue);
        expect(limited.hasUnlimitedTracks, isFalse);
        expect(limited.hasUnlimitedPlaylists, isFalse);
      },
    );
  });

  group('UserSubscription', () {
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

    test('should return valid UserSubscription from JSON', () {
      final result = UserSubscription.fromJson(tUserSubscriptionJson);
      expect(result.subscriptionId, 'sub-456');
      expect(result.userId, 'user-789');
      expect(result.status, 'active');
      expect(result.plan.name, 'premium');
    });

    test('isActive and isCanceled should work correctly', () {
      final active = UserSubscription.fromJson(tUserSubscriptionJson);
      final canceled = UserSubscription.fromJson({
        ...tUserSubscriptionJson,
        'status': 'canceled',
      });
      final expired = UserSubscription.fromJson({
        ...tUserSubscriptionJson,
        'status': 'expired',
      });

      expect(active.isActive, isTrue);
      expect(active.isCanceled, isFalse);
      expect(canceled.isCanceled, isTrue);
      expect(canceled.isActive, isFalse);
      expect(expired.isActive, isFalse);
      expect(expired.isCanceled, isFalse);
    });

    test('isPremium should work correctly', () {
      final activePremium = UserSubscription.fromJson(tUserSubscriptionJson);
      final canceledPremium = UserSubscription.fromJson({
        ...tUserSubscriptionJson,
        'status': 'canceled',
      });
      final expiredPremium = UserSubscription.fromJson({
        ...tUserSubscriptionJson,
        'status': 'expired',
      });

      final freePlanJson = {...tPlanJson, 'name': 'free'};
      final activeFree = UserSubscription.fromJson({
        ...tUserSubscriptionJson,
        'plan': freePlanJson,
      });

      expect(activePremium.isPremium, isTrue);
      expect(canceledPremium.isPremium, isTrue);
      expect(expiredPremium.isPremium, isFalse);
      expect(activeFree.isPremium, isFalse);
    });
  });

  group('CheckoutSession', () {
    final tPlanJson = {
      'subscription_plan_id': 'plan-123',
      'name': 'premium',
      'price': '9.99',
      'duration_days': 30,
      'track_limit': null,
      'playlist_limit': null,
    };

    final tCheckoutSessionJson = {
      'transaction_id': 'trans-000',
      'user_subscription_id': 'sub-456',
      'checkout_status': 'pending',
      'payment_method': 'stripe',
      'payment_url': 'https://stripe.com/pay',
      'plan': tPlanJson,
    };

    test('should return valid CheckoutSession from JSON', () {
      final result = CheckoutSession.fromJson(tCheckoutSessionJson);
      expect(result.transactionId, 'trans-000');
      expect(result.subscriptionId, 'sub-456');
      expect(result.checkoutStatus, 'pending');
      expect(result.paymentUrl, 'https://stripe.com/pay');
    });

    test('should handle missing payment_url', () {
      final result = CheckoutSession.fromJson({
        ...tCheckoutSessionJson,
        'payment_url': null,
      });
      expect(result.paymentUrl, '');
    });
  });
}
