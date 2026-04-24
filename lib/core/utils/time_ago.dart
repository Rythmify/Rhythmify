// lib/core/utils/time_ago.dart

/// Returns a human-readable relative time string.
/// Examples: "just now", "2m ago", "3h ago", "yesterday", "Apr 18", "2025"
String timeAgo(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);

  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';

  // Same year → "Apr 18", different year → "2024"
  if (dt.year == now.year) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  return '${dt.year}';
}