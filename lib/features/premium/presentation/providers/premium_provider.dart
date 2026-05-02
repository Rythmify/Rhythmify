/// Manages all subscription logic and state for the premium system.
///
/// Handles:
/// - Loading subscription plans and user subscription
/// - Checkout flow (create → confirm → refresh state)
/// - Subscription cancellation
/// - Feature access rules (upload, playlists, download)
///
/// Key state:
/// - subscription: current user subscription
/// - plans: available plans from backend
/// - isLoading / isCheckingOut: UI loading states
/// - checkoutSuccess: signals successful payment
/// - isInitialized: ensures initial data is loaded before UI renders
///
/// Feature gates:
/// - canUploadMoreTracks
/// - canCreateMorePlaylists
/// - canDownload / canListenOffline
///
/// Notes:
/// - Free limits are enforced via constants (track/playlist caps)
/// - All API calls go through PremiumRemoteDatasource
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/user_subscription.dart';
import '../../data/datasources/premium_remote_datasource.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../profile/presentation/providers/profile_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FREE PLAN HARD LIMITS  (from OpenAPI spec)
// ─────────────────────────────────────────────────────────────────────────────

const kFreeTrackLimit = 3; // POST /tracks → 403 SUBSCRIPTION_LIMIT_REACHED
const kFreePlaylistLimit = 2; // enforced client-side before POST /playlists
const kFreeCanDownload = false;

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

  final bool
  isInitialized; // true after both loadPlans + loadMySubscription complete

  const PremiumState({
    this.subscription,
    this.plans = const [],
    this.isLoading = false,
    this.isCheckingOut = false,
    this.error,
    this.checkoutSuccess = false,
    this.isInitialized = false,
  });

  // ── Core premium flag ──────────────────────────────────────────────────────
  bool get isPremium => subscription?.isPremium ?? false;
  bool get isFree => !isPremium;

  // ── Feature gates — checked before any gated action ───────────────────────
  bool get canUploadMoreTracks => isPremium; // free capped at kFreeTrackLimit
  bool get canCreateMorePlaylists =>
      isPremium; // free capped at kFreePlaylistLimit
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
    bool? isInitialized,
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
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────

class PremiumNotifier extends Notifier<PremiumState> {
  @override
  PremiumState build() {
    // 1. Listen to Auth State changes to handle Login/Logout
    ref.listen(authProvider, (previous, next) {
      if (next is AuthUnauthenticated) {
        // Clear all premium data on logout
        state = const PremiumState();
      } else if (next is AuthAuthenticated && previous is! AuthAuthenticated) {
        // Re-initialize for the new user
        _init();
      }
    });

    // 2. Initial load
    Future.microtask(_init);
    return const PremiumState();
  }

  PremiumRemoteDatasource get _ds => ref.read(premiumDatasourceProvider);

  Future<void> _init() async {
    // 1. Ensure we are authenticated before trying to fetch
    final authState = ref.read(authProvider);
    if (authState is! AuthAuthenticated) return;

    // 2. Fetch Profile FIRST (The Source of Truth)
    // We wait for this to complete before marking initialization as finished.
    await ref.read(ownProfileProvider.notifier).loadProfile(userId: 'me');

    // 3. Load plans and the detailed subscription record
    await loadPlans();
    await loadMySubscription();

    // 4. Mark init complete - now other modules (like Ads) can trust the status
    state = state.copyWith(isInitialized: true);
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // 404 = no active subscription — free tier, not an error
        state = state.copyWith(isLoading: false, clearSubscription: true);
      } else {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Called from CheckoutScreen after user confirms payment.
  /// Flow: POST /subscriptions/checkout → POST /subscriptions/mock-confirm/{id}
  Future<void> checkout(String planId) async {
    state = state.copyWith(
      isCheckingOut: true,
      clearError: true,
      checkoutSuccess: false,
    );
    try {
      String transactionId;

      // Resolve planId — if empty, fetch plans and find premium UUID
      // Fallback to known backend UUID if plans endpoint returns empty
      const kFallbackPremiumPlanId = '2';
      String resolvedPlanId = planId;
      if (resolvedPlanId.isEmpty) {
        if (state.plans.isEmpty) await loadPlans();
        final premiumPlan = state.plans.isNotEmpty
            ? state.plans.firstWhere(
                (p) => p.isPremium,
                orElse: () => state.plans.last,
              )
            : null;
        resolvedPlanId = premiumPlan?.planId ?? kFallbackPremiumPlanId;
      }

      try {
        // Step 1: Try creating a new checkout session
        final session = await _ds.startCheckout(resolvedPlanId);
        transactionId = session.transactionId;
      } on DioException catch (e) {
        final code = e.response?.data?['error']?['code'] as String?;

        // Already active — treat as success
        if (e.response?.statusCode == 409 &&
            code == 'SUBSCRIPTION_ALREADY_ACTIVE') {
          await loadMySubscription();
          state = state.copyWith(isCheckingOut: false, checkoutSuccess: true);
          return;
        }

        // Pending checkout exists — fetch and confirm it
        if (e.response?.statusCode == 409 &&
            code == 'SUBSCRIPTION_CHECKOUT_PENDING') {
          final pendingId = await _ds.fetchPendingTransactionId(resolvedPlanId);
          if (pendingId == null) {
            state = state.copyWith(
              isCheckingOut: false,
              error: 'Could not find pending transaction. Please try again.',
            );
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

      // Step 3: Wait briefly for backend processing
      await Future.delayed(const Duration(seconds: 2));

      // Step 4: Refresh — subscription and profile are now active/updated
      await loadMySubscription();
      await ref.read(ownProfileProvider.notifier).loadProfile(userId: 'me');

      state = state.copyWith(isCheckingOut: false, checkoutSuccess: true);
    } on DioException catch (e) {
      final message =
          e.response?.data?['error']?['message'] as String? ??
          e.message ??
          'Payment failed. Please try again.';
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
      await ref.read(ownProfileProvider.notifier).loadProfile(userId: 'me');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearCheckoutSuccess() => state = state.copyWith(checkoutSuccess: false);

  void clearError() => state = state.copyWith(clearError: true);
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
  // 1. Primary Source: Subscription Provider (Detailed state)
  final subscriptionPremium = ref.watch(premiumProvider).isPremium;
  if (subscriptionPremium) return true;

  // 2. Fallback Source: Own Profile (Convenience flag from backend)
  final profileState = ref.watch(ownProfileProvider);
  if (profileState is ProfileLoaded) {
    return profileState.profile.isUserPremium;
  }

  return false;
});

/// Granular gate providers — use these instead of rolling your own checks.
final canUploadTracksProvider = Provider<bool>((ref) {
  return ref.watch(isPremiumProvider);
});

final canCreatePlaylistsProvider = Provider<bool>((ref) {
  return ref.watch(isPremiumProvider);
});

final canDownloadProvider = Provider<bool>((ref) {
  return ref.watch(isPremiumProvider);
});
