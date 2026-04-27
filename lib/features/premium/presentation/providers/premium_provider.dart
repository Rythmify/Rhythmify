import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/user_subscription.dart';
import '../../data/datasources/premium_remote_datasource.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FREE PLAN HARD LIMITS  (from OpenAPI spec)
// ─────────────────────────────────────────────────────────────────────────────

const kFreeTrackLimit    = 3;   // POST /tracks → 403 SUBSCRIPTION_LIMIT_REACHED
const kFreePlaylistLimit = 2;   // enforced client-side before POST /playlists
const kFreeCanDownload   = false;

// ─────────────────────────────────────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────────────────────────────────────

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

  // ── Core premium flag ──────────────────────────────────────────────────────
  bool get isPremium => subscription?.isPremium ?? false;
  bool get isFree    => !isPremium;

  // ── Feature gates — checked before any gated action ───────────────────────
  bool get canUploadMoreTracks => isPremium;   // free capped at kFreeTrackLimit
  bool get canCreateMorePlaylists => isPremium; // free capped at kFreePlaylistLimit
  bool get canDownload => isPremium;
  bool get canListenOffline => isPremium;

  // ── Subscription display helpers ───────────────────────────────────────────
  String? get endDate => subscription?.endDate;
  bool get isCanceled => subscription?.isCanceled ?? false;

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
      subscription: clearSubscription ? null : (subscription ?? this.subscription),
      plans: plans ?? this.plans,
      isLoading: isLoading ?? this.isLoading,
      isCheckingOut: isCheckingOut ?? this.isCheckingOut,
      error: clearError ? null : (error ?? this.error),
      checkoutSuccess: checkoutSuccess ?? this.checkoutSuccess,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────

class PremiumNotifier extends Notifier<PremiumState> {
  @override
  PremiumState build() {
    Future.microtask(_init);
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
      // 404 = no active subscription — free tier, not an error
      state = state.copyWith(isLoading: false, clearSubscription: true);
    }
  }

  /// Called from CheckoutScreen after user confirms payment.
  /// Flow: POST /subscriptions/checkout → POST /subscriptions/mock-confirm/{id}
  Future<void> checkout(String planId) async {
    state = state.copyWith(
        isCheckingOut: true, clearError: true, checkoutSuccess: false);
    try {
      String transactionId;

      // Resolve planId — if empty, fetch plans and find premium UUID
      // Fallback to known backend UUID if plans endpoint returns empty
      const _kFallbackPremiumPlanId = 'b0000002-0000-0000-0000-000000000000';
      String resolvedPlanId = planId;
      if (resolvedPlanId.isEmpty) {
        if (state.plans.isEmpty) await loadPlans();
        final premiumPlan = state.plans.isNotEmpty
            ? state.plans.firstWhere(
                (p) => p.isPremium,
                orElse: () => state.plans.last,
              )
            : null;
        resolvedPlanId = premiumPlan?.planId ?? _kFallbackPremiumPlanId;
      }

      try {
        // Step 1: Try creating a new checkout session
        final session = await _ds.startCheckout(resolvedPlanId);
        transactionId = session.transactionId;
      } on DioException catch (e) {
        // 409 = pending checkout already exists — skip checkout, fetch existing
        final code = e.response?.data?['error']?['code'] as String?;
        if (e.response?.statusCode == 409 &&
            code == 'SUBSCRIPTION_CHECKOUT_PENDING') {
          final pendingId = await _ds.fetchPendingTransactionId(resolvedPlanId);
          if (pendingId == null) {
            state = state.copyWith(
                isCheckingOut: false,
                error: 'Could not find pending transaction. Please try again.');
            return;
          }
          transactionId = pendingId;
          // Go straight to mock-confirm — do NOT call checkout again
        } else {
          rethrow;
        }
      }

      // Step 2: Confirm the transaction (mock Stripe webhook)
      await _ds.confirmMockPayment(transactionId);

      // Step 3: Refresh — subscription is now active
      await loadMySubscription();

      state = state.copyWith(isCheckingOut: false, checkoutSuccess: true);
    } on DioException catch (e) {
      final message = e.response?.data?['error']?['message'] as String?
          ?? e.message
          ?? 'Payment failed. Please try again.';
      state = state.copyWith(isCheckingOut: false, error: message);
    } catch (e) {
      state = state.copyWith(isCheckingOut: false, error: e.toString());
    }
  }

  /// Cancel sets auto_renew=false. User keeps premium until end_date.
  Future<void> cancel() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _ds.cancelSubscription();
      await loadMySubscription();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearCheckoutSuccess() =>
      state = state.copyWith(checkoutSuccess: false);
}

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

final premiumProvider = NotifierProvider<PremiumNotifier, PremiumState>(
  PremiumNotifier.new,
);

/// Quick boolean — import this anywhere to gate a feature.
/// Usage:  final isPremium = ref.watch(isPremiumProvider);
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(premiumProvider).isPremium;
});

/// Granular gate providers — use these instead of rolling your own checks.
final canUploadTracksProvider = Provider<bool>((ref) {
  return ref.watch(premiumProvider).canUploadMoreTracks;
});

final canCreatePlaylistsProvider = Provider<bool>((ref) {
  return ref.watch(premiumProvider).canCreateMorePlaylists;
});

final canDownloadProvider = Provider<bool>((ref) {
  return ref.watch(premiumProvider).canDownload;
});