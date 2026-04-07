import '../../../../core/domain/entities/track.dart';

class HotForYou {
  final Track track;
  final String reason;
  final DateTime validUntil;

  const HotForYou({
    required this.track,
    required this.reason,
    required this.validUntil,
  });
}
