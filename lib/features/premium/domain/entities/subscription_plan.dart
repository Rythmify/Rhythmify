class SubscriptionPlan {
  final String planId;       // UUID — e.g. "a1b2c3d4-..."  sent to /subscriptions/checkout
  final String name;         // "free" | "premium"
  final String price;        // "4.99"
  final int? durationDays;
  final int? trackLimit;     // null = unlimited
  final int? playlistLimit;  // null = unlimited

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