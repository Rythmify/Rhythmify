import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_entity.dart';
import '../../../../core/domain/entities/track.dart';

/// Base class for all profile states in Rythmify.
///
/// Used with [ProfileNotifier] (a Riverpod [Notifier]) to represent
/// the current state of profile data loading, saving, and track pagination.
/// Extends [Equatable] so Riverpod can detect state changes efficiently.
abstract class ProfileState extends Equatable {
  const ProfileState();

  /// Default props — subclasses override to add their own fields.
  @override
  List<Object?> get props => [];
}

/// The initial state before any profile has been loaded.
///
/// Emitted when [ProfileNotifier] is first built. Pages must call
/// [ProfileNotifier.loadProfile] explicitly in `initState` via
/// `Future.microtask` to trigger a load.
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Emitted while the profile is being fetched from the datasource.
///
/// A [CircularProgressIndicator] is shown during this state in
/// [PublicProfilePage] and [EditProfilePage].
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Emitted when the profile has been successfully loaded.
///
/// Contains the [profile] entity and the paginated list of [likedTracks].
/// Track pagination state ([isLoadingTracks], [hasMoreTracks]) is also
/// managed here.
class ProfileLoaded extends ProfileState {
  /// The loaded profile data.
  final ProfileEntity profile;

  /// The accumulated list of liked tracks across all loaded pages.
  final List<Track> likedTracks;

  /// Whether the next page of liked tracks is currently being fetched.
  ///
  /// Shows a bottom spinner in [PublicProfilePage] and [LikesPage]
  /// when `true`.
  final bool isLoadingTracks;

  /// Whether more pages of liked tracks are available.
  ///
  /// Set to `false` when a page returns fewer than the requested limit
  /// (20), preventing further pagination requests.
  final bool hasMoreTracks;

  /// Whether a save operation (update, upload, delete) is in progress.
  ///
  /// Disables the Save button and shows a spinner in [EditProfilePage]
  /// when `true`.
  final bool isSaving;

  /// Creates a [ProfileLoaded] state with the required [profile].
  ///
  /// [likedTracks] defaults to an empty list.
  /// [isLoadingTracks], [hasMoreTracks], and [isSaving] have sensible defaults.
  const ProfileLoaded({
    required this.profile,
    this.likedTracks = const [],
    this.isLoadingTracks = false,
    this.hasMoreTracks = true,
    this.isSaving = false,
  });

  /// Returns a copy of this state with updated fields.
  ///
  /// Any field not provided retains its current value.
  ProfileLoaded copyWith({
    ProfileEntity? profile,
    List<Track>? likedTracks,
    bool? isLoadingTracks,
    bool? hasMoreTracks,
    bool? isSaving,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      likedTracks: likedTracks ?? this.likedTracks,
      isLoadingTracks: isLoadingTracks ?? this.isLoadingTracks,
      hasMoreTracks: hasMoreTracks ?? this.hasMoreTracks,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  /// Props used by [Equatable] to determine equality between states.
  @override
  List<Object?> get props => [
        profile,
        likedTracks,
        isLoadingTracks,
        hasMoreTracks,
        isSaving,
      ];
}

/// Emitted when loading the profile fails.
///
/// The [message] comes from the underlying [Failure] and is displayed
/// alongside a Retry button in [PublicProfilePage].
class ProfileError extends ProfileState {
  /// The human-readable error message from the underlying [Failure].
  final String message;

  /// Creates a [ProfileError] with the given [message].
  const ProfileError(this.message);

  /// Props include [message] so identical errors are deduplicated.
  @override
  List<Object?> get props => [message];
}