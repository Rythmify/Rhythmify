/// Represents the current subscription state of a user.
///
/// This model is retrieved from:
/// GET /subscriptions/me
///
/// Responsibilities:
/// - Store subscription lifecycle state
/// - Link user to their active subscription plan
/// - Provide derived state helpers for UI/business logic
///
/// Key Fields:
/// - subscriptionId: Unique subscription identifier (UUID)
/// - userId: ID of the subscribed user
/// - status: Subscription state (pending, active, canceled, expired)
/// - startDate: Subscription start date
/// - endDate: Optional expiration date
/// - autoRenew: Whether subscription renews automatically
/// - plan: Associated SubscriptionPlan
///
/// Helper Methods:
/// - isActive: true if status == active
/// - isCanceled: true if status == canceled
/// - isPremium: true if active and plan is premium
///
/// Notes:
/// - This model is immutable
/// - Business logic is intentionally minimal and UI-friendly
import 'subscription_plan.dart';

class UserSubscription {
  final String subscriptionId; // UUID
  final String userId;
  final String status; // "pending" | "active" | "canceled" | "expired"
  final String startDate;
  final String? endDate;
  final bool autoRenew;
  final SubscriptionPlan plan;

  const UserSubscription({
    required this.subscriptionId,
    required this.userId,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.autoRenew,
    required this.plan,
  });

  bool get isActive => status == 'active';
  bool get isCanceled => status == 'canceled';
  bool get isPremium => isActive && plan.isPremium;

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      subscriptionId: json['user_subscription_id'].toString(),
      userId: json['user_id'] as String,
      status: json['status'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String?,
      autoRenew: json['auto_renew'] as bool,
      plan: SubscriptionPlan.fromJson(json['plan'] as Map<String, dynamic>),
    );
  }
}
