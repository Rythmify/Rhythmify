class SubscriptionPlan {
  final int planId;
  final String name; // "free" | "premium"
  final String price; // "4.99"
  final int? durationDays; // null for free
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
      planId: json['subscription_plan_id'] as int,
      name: json['name'] as String,
      price: json['price'] as String,
      durationDays: json['duration_days'] as int?,
      trackLimit: json['track_limit'] as int?,
      playlistLimit: json['playlist_limit'] as int?,
    );
  }
}