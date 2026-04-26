import 'subscription_plan.dart';

class CheckoutSession {
  final String transactionId;   // UUID string e.g. "f2c5b997-4756-..."
  final String subscriptionId;  // UUID string
  final String checkoutStatus;
  final String paymentMethod;
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
      transactionId: json['transaction_id'].toString(),
      subscriptionId: json['user_subscription_id'].toString(),
      checkoutStatus: json['checkout_status'] as String,
      paymentMethod: json['payment_method'] as String,
      paymentUrl: (json['payment_url'] as String?) ?? '',
      plan: SubscriptionPlan.fromJson(json['plan'] as Map<String, dynamic>),
    );
  }
}