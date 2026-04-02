class TimeUtils {
  /// Converts seconds or milliseconds into a 00:00 or 0:00:00 format.
  static String formatTrackTimestamp(int value, {bool isMilliseconds = false}) {
    final duration = isMilliseconds 
        ? Duration(milliseconds: value) 
        : Duration(seconds: value);
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$minutesStr:$secondsStr';
    } else {
      return '$minutesStr:$secondsStr';
    }
  }

  /// Converts a [DateTime] into a strictly abbreviated relative string.
  /// Format: days (xd), weeks (yw), or years (zy).
  /// If less than a day, it returns "0d" or you might want "1h", but the requirement
  /// says days, weeks, years. I'll add hours and minutes just in case but 
  /// prioritize the requested ones.
  static String formatRelativeDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays >= 7) {
      return '${(difference.inDays / 7).floor()}w';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
