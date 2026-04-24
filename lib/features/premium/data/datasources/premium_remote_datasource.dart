import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/user_subscription.dart';
import '../../domain/entities/checkout_session.dart';

// Replace with your actual ApiClient provider import:
// import 'package:rythmify/core/network/api_client.dart';

const _base = 'https://rythmify-backend-dev.livelypebble-6b7965ef.uaenorth.azurecontainerapps.io/api/v1';

class PremiumRemoteDatasource {
  final Dio _dio;
  const PremiumRemoteDatasource(this._dio);

  // GET /subscriptions/plans  (public)
  Future<List<SubscriptionPlan>> fetchPlans() async {
    final res = await _dio.get('$_base/subscriptions/plans');
    final items = res.data['data']['items'] as List<dynamic>;
    return items
        .map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // GET /subscriptions/me
  Future<UserSubscription> fetchMySubscription() async {
    final res = await _dio.get('$_base/subscriptions/me');
    return UserSubscription.fromJson(
        res.data['data'] as Map<String, dynamic>);
  }

  // POST /subscriptions/checkout
  Future<CheckoutSession> startCheckout(int planId) async {
    final res = await _dio.post(
      '$_base/subscriptions/checkout',
      data: {'subscription_plan_id': planId},
    );
    return CheckoutSession.fromJson(
        res.data['data'] as Map<String, dynamic>);
  }

  // POST /subscriptions/mock-confirm/{transactionId}
  Future<void> confirmMockPayment(int transactionId) async {
    await _dio.post('$_base/subscriptions/mock-confirm/$transactionId');
  }

  // POST /subscriptions/cancel
  Future<void> cancelSubscription() async {
    await _dio.post('$_base/subscriptions/cancel');
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────
// Wire up your real ApiClient dio instance here.
final premiumDatasourceProvider = Provider<PremiumRemoteDatasource>((ref) {
  // final dio = ref.watch(apiClientProvider).dio;
  final dio = Dio(); // replace with your ApiClient
  return PremiumRemoteDatasource(dio);
});