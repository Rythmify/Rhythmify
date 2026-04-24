import 'subscription_plan.dart';

class CheckoutSession {
  final int transactionId;
  final int subscriptionId;
  final String checkoutStatus; // "pending" | "paid" | "failed"
  final String paymentMethod; // "mock"
  final String paymentUrl;
  final SubscriptionPlan plan;

  const CheckoutSession({
    required this.transactionId,
    required this.subscriptionId,
    required this.checkoutStatus,
    required this.paymentMethod,
    required this.paymentUrl,
    required this.plan,
  });

  factory CheckoutSession.fromJson(Map<String, dynamic> json) {
    return CheckoutSession(
      transactionId: json['transaction_id'] as int,
      subscriptionId: json['user_subscription_id'] as int,
      checkoutStatus: json['checkout_status'] as String,
      paymentMethod: json['payment_method'] as String,
      paymentUrl: json['payment_url'] as String,
      plan: SubscriptionPlan.fromJson(json['plan'] as Map<String, dynamic>),
    );
  }
}