import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/user_subscription.dart';
import '../../data/datasources/premium_remote_datasource.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class PremiumState {
  final UserSubscription? subscription;
  final List<SubscriptionPlan> plans;
  final bool isLoading;
  final bool isCheckingOut;
  final String? error;
  final bool checkoutSuccess;

  const PremiumState({
    this.subscription,
    this.plans = const [],
    this.isLoading = false,
    this.isCheckingOut = false,
    this.error,
    this.checkoutSuccess = false,
  });

  bool get isPremium => subscription?.isPremium ?? false;
  bool get isFree => !isPremium;

  PremiumState copyWith({
    UserSubscription? subscription,
    List<SubscriptionPlan>? plans,
    bool? isLoading,
    bool? isCheckingOut,
    String? error,
    bool? checkoutSuccess,
    bool clearError = false,
    bool clearSubscription = false,
  }) {
    return PremiumState(
      subscription: clearSubscription
          ? null
          : (subscription ?? this.subscription),
      plans: plans ?? this.plans,
      isLoading: isLoading ?? this.isLoading,
      isCheckingOut: isCheckingOut ?? this.isCheckingOut,
      error: clearError ? null : (error ?? this.error),
      checkoutSuccess: checkoutSuccess ?? this.checkoutSuccess,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class PremiumNotifier extends Notifier<PremiumState> {
  @override
  PremiumState build() {
    // Kick off initial load
    Future.microtask(() => _init());
    return const PremiumState();
  }

  PremiumRemoteDatasource get _ds => ref.read(premiumDatasourceProvider);

  Future<void> _init() async {
    await loadPlans();
    await loadMySubscription();
  }

  Future<void> loadPlans() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final plans = await _ds.fetchPlans();
      state = state.copyWith(plans: plans, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMySubscription() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final sub = await _ds.fetchMySubscription();
      state = state.copyWith(subscription: sub, isLoading: false);
    } catch (e) {
      // 404 means no active subscription – that's fine
      state = state.copyWith(isLoading: false, clearSubscription: true);
    }
  }

  Future<void> checkout(int planId) async {
    state = state.copyWith(
      isCheckingOut: true,
      clearError: true,
      checkoutSuccess: false,
    );
    try {
      final session = await _ds.startCheckout(planId);
      await _ds.confirmMockPayment(session.transactionId);
      await loadMySubscription();
      state = state.copyWith(isCheckingOut: false, checkoutSuccess: true);
    } catch (e) {
      state = state.copyWith(isCheckingOut: false, error: e.toString());
    }
  }

  Future<void> cancel() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _ds.cancelSubscription();
      await loadMySubscription();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearCheckoutSuccess() {
    state = state.copyWith(checkoutSuccess: false);
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final premiumProvider = NotifierProvider<PremiumNotifier, PremiumState>(
  PremiumNotifier.new,
);

/// Convenience provider — import this in any feature to gate premium content.
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(premiumProvider).isPremium;
});
