import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_entity.dart';
import '../../../../core/domain/entities/track.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  final List<Track> likedTracks;
  final bool isLoadingTracks;
  final bool hasMoreTracks;
  final bool isSaving;

  const ProfileLoaded({
    required this.profile,
    this.likedTracks = const [],
    this.isLoadingTracks = false,
    this.hasMoreTracks = true,
    this.isSaving = false,
  });

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

  @override
  List<Object?> get props => [
    profile,
    likedTracks,
    isLoadingTracks,
    hasMoreTracks,
    isSaving,
  ];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
