import 'subscription_plan.dart';

/// Represents a subscription checkout session created when a user initiates
/// a purchase flow for a premium plan.
///
/// This model is returned from:
/// POST /subscriptions/checkout
///
/// Responsibilities:
/// - Holds transaction identifiers required for payment tracking
/// - Contains checkout status and payment metadata
/// - Provides access to the selected subscription plan
///
/// Key Fields:
/// - transactionId: Unique identifier for payment transaction (UUID)
/// - subscriptionId: The created or pending user subscription ID
/// - checkoutStatus: Current status of checkout (e.g., pending, completed)
/// - paymentMethod: Payment provider/method used
/// - paymentUrl: URL for completing payment (if required)
/// - plan: The selected SubscriptionPlan object
///
/// Notes:
/// - This model is immutable.
/// - JSON parsing assumes backend returns nested "plan" object.
class CheckoutSession {
  final String transactionId; // UUID string e.g. "f2c5b997-4756-..."
  final String subscriptionId; // UUID string
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
