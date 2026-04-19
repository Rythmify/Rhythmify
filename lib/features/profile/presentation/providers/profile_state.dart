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

  /// Tracks uploaded by the user.
  final List<Track> uploadedTracks;
  final bool isLoadingUploads;
  final bool hasMoreUploads;

  /// Tracks liked by the user.
  final List<Track> likedTracks;
  final bool isLoadingLikes;
  final bool hasMoreLikes;

  /// Tracks reposted by the user.
  final List<Track> repostedTracks;
  final bool isLoadingReposts;
  final bool hasMoreReposts;

  /// Whether a save operation (update, upload, delete) is in progress.
  final bool isSaving;

  const ProfileLoaded({
    required this.profile,
    this.uploadedTracks = const [],
    this.isLoadingUploads = false,
    this.hasMoreUploads = true,
    this.likedTracks = const [],
    this.isLoadingLikes = false,
    this.hasMoreLikes = true,
    this.repostedTracks = const [],
    this.isLoadingReposts = false,
    this.hasMoreReposts = true,
    this.isSaving = false,
  });

  ProfileLoaded copyWith({
    ProfileEntity? profile,
    List<Track>? uploadedTracks,
    bool? isLoadingUploads,
    bool? hasMoreUploads,
    List<Track>? likedTracks,
    bool? isLoadingLikes,
    bool? hasMoreLikes,
    List<Track>? repostedTracks,
    bool? isLoadingReposts,
    bool? hasMoreReposts,
    bool? isSaving,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      uploadedTracks: uploadedTracks ?? this.uploadedTracks,
      isLoadingUploads: isLoadingUploads ?? this.isLoadingUploads,
      hasMoreUploads: hasMoreUploads ?? this.hasMoreUploads,
      likedTracks: likedTracks ?? this.likedTracks,
      isLoadingLikes: isLoadingLikes ?? this.isLoadingLikes,
      hasMoreLikes: hasMoreLikes ?? this.hasMoreLikes,
      repostedTracks: repostedTracks ?? this.repostedTracks,
      isLoadingReposts: isLoadingReposts ?? this.isLoadingReposts,
      hasMoreReposts: hasMoreReposts ?? this.hasMoreReposts,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [
    profile,
    uploadedTracks,
    isLoadingUploads,
    hasMoreUploads,
    likedTracks,
    isLoadingLikes,
    hasMoreLikes,
    repostedTracks,
    isLoadingReposts,
    hasMoreReposts,
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
