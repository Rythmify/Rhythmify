/// This class is responsible for handling all remote API calls related to
/// the premium subscription system in the app.
///
/// It acts as the data layer between the domain layer and the backend
/// subscription service, using Dio for HTTP communication.
///
/// Responsibilities:
/// - Fetch available subscription plans
/// - Retrieve the current user's subscription
/// - Start a checkout session for a selected plan
/// - Confirm mock payments (used for testing or sandbox flows)
/// - Cancel an active subscription
/// - Retrieve pending transactions for checkout flow recovery
///
/// API Endpoints Used:
/// - GET    /subscriptions/plans
/// - GET    /subscriptions/me
/// - POST   /subscriptions/checkout
/// - POST   /subscriptions/mock-confirm/{transaction_id}
/// - POST   /subscriptions/cancel
/// - GET    /subscriptions/transactions
///
/// Authentication:
/// Most endpoints require a Bearer token, which is handled automatically
/// by the shared ApiClient (via Dio interceptors).
///
/// Notes:
/// - All JSON parsing is delegated to domain entities.
/// - This class does not contain business logic.
/// - It assumes backend response structure consistency.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/core/network/api_client.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/user_subscription.dart';
import '../../domain/entities/checkout_session.dart';

class PremiumRemoteDatasource {
  final Dio _dio;
  const PremiumRemoteDatasource(this._dio);

  // GET /subscriptions/plans  (public)
  Future<List<SubscriptionPlan>> fetchPlans() async {
    final res = await _dio.get('/subscriptions/plans');
    final items = res.data['data']['items'] as List<dynamic>;
    return items
        .map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // GET /subscriptions/me  (Bearer required)
  Future<UserSubscription> fetchMySubscription() async {
    final res = await _dio.get('/subscriptions/me');
    return UserSubscription.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  // POST /subscriptions/checkout  (Bearer required)
  // Body: { "subscription_plan_id": int }
  Future<CheckoutSession> startCheckout(String planId) async {
    final res = await _dio.post(
      '/subscriptions/checkout',
      data: {'subscription_plan_id': planId},
    );
    return CheckoutSession.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  // POST /subscriptions/mock-confirm/{transaction_id}  (Bearer required)
  // transaction_id is a UUID string e.g. "f2c5b997-4756-4874-ab23-5ee78ecd4259"
  Future<void> confirmMockPayment(String transactionId) async {
    await _dio.post('/subscriptions/mock-confirm/$transactionId');
  }

  // POST /subscriptions/cancel  (Bearer required)
  Future<void> cancelSubscription() async {
    await _dio.post('/subscriptions/cancel');
  }

  // GET /subscriptions/transactions — fetch pending transaction UUID
  Future<String?> fetchPendingTransactionId(String planId) async {
    final res = await _dio.get(
      '/subscriptions/transactions',
      queryParameters: {'limit': 5, 'offset': 0, 'payment_status': 'pending'},
    );
    // Response shape: { "data": [ { "transaction_id": "uuid", ... } ] }
    final items = res.data['data'] as List<dynamic>? ?? [];
    if (items.isEmpty) return null;
    return items.first['transaction_id']?.toString();
  }
}

// ── Provider — uses the global apiClient singleton which has the Bearer
//              token interceptor and auto-refresh already wired in ────────────
final premiumDatasourceProvider = Provider<PremiumRemoteDatasource>((ref) {
  return PremiumRemoteDatasource(apiClient.dio);
});
