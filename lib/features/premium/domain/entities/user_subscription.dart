import 'subscription_plan.dart';

class UserSubscription {
  final int subscriptionId;
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
      subscriptionId: json['user_subscription_id'] as int,
      userId: json['user_id'] as String,
      status: json['status'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String?,
      autoRenew: json['auto_renew'] as bool,
      plan: SubscriptionPlan.fromJson(json['plan'] as Map<String, dynamic>),
    );
  }
}
