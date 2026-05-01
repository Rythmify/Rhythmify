/// Represents a subscription plan offered by the platform (e.g., free or
/// premium tiers).
///
/// This model is used across:
/// - Subscription listing screens
/// - Checkout flow
/// - Subscription validation logic
///
/// Responsibilities:
/// - Define pricing and limits of a plan
/// - Provide helper methods to determine plan type and restrictions
///
/// Key Fields:
/// - planId: Unique identifier (UUID) used for checkout requests
/// - name: Plan type ("free", "premium", etc.)
/// - price: Plan price as string (backend formatted)
/// - durationDays: Duration of subscription in days
/// - trackLimit: Max number of tracks allowed (null = unlimited)
/// - playlistLimit: Max number of playlists allowed (null = unlimited)
///
/// Helper Methods:
/// - isFree: checks if plan is free tier
/// - isPremium: checks if plan is premium tier
/// - hasUnlimitedTracks: true if no track limit exists
/// - hasUnlimitedPlaylists: true if no playlist limit exists
///
/// Notes:
/// - Null limits are interpreted as "unlimited access"
/// - Backend provides raw values directly mapped here
class SubscriptionPlan {
  final String
  planId; // UUID — e.g. "a1b2c3d4-..."  sent to /subscriptions/checkout
  final String name; // "free" | "premium"
  final String price; // "4.99"
  final int? durationDays;
  final int? trackLimit; // null = unlimited
  final int? playlistLimit; // null = unlimited

  const SubscriptionPlan({
    required this.planId,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.trackLimit,
    required this.playlistLimit,
  });

  bool get isFree => name == 'free';
  bool get isPremium => name == 'premium';
  bool get hasUnlimitedTracks => trackLimit == null;
  bool get hasUnlimitedPlaylists => playlistLimit == null;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      // Backend returns subscription_plan_id as a UUID string
      planId: json['subscription_plan_id'].toString(),
      name: json['name'] as String,
      price: json['price'] as String,
      durationDays: json['duration_days'] as int?,
      trackLimit: json['track_limit'] as int?,
      playlistLimit: json['playlist_limit'] as int?,
    );
  }
}
