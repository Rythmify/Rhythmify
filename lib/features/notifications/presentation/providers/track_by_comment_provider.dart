import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';
import 'package:rythmify/features/messaging/presentation/providers/get_track_details_provider.dart';
import 'package:rythmify/features/notifications/domain/usecases/get_track_id_by_comment_id_usecase.dart';
import 'package:rythmify/features/notifications/presentation/providers/repo_provider.dart';

/// Resolves full track details for a comment-type notification.
///
/// Step 1: `GET /comments/{commentId}` → `track_id`.
/// Step 2: delegates to [getTrackDetailsProvider] → [SharedEmbed] (track ID, title, cover).
/// Returns `null` if the comment has no `track_id`.
/// Cached by Riverpod — multiple tiles for the same comment share one request.
final trackByCommentProvider=
  FutureProvider.family<({SharedEmbed? embed, bool isLikedByMe}), String>((ref,commentId)async{
    final result = await GetTrackIdByCommentIdUsecase(ref.read(repositoryprovider)).call(commentId);
    final embed=result.trackId!=null? await ref.read(getTrackDetailsProvider(result.trackId!).future): null;
    return (embed: embed,isLikedByMe: result.isLikedByMe);
});
