import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/track_upload/data/datasources/upload_track_remote_datasource.dart';
import 'package:rythmify/features/track_upload/data/repositories/upload_track_repository_impl.dart';
import 'package:rythmify/features/track_upload/domain/entities/track_draft.dart';
import 'package:rythmify/features/track_upload/domain/usecases/upload_track_usecase.dart';
import 'package:rythmify/core/domain/entities/track.dart' as track_entity;
import 'package:rythmify/features/track/presentation/providers/track_dependency_providers.dart';
import 'package:flutter/foundation.dart';

/// Provider: UploadFormNotifier & UploadFormState
///
/// Manages all UI state for the Upload Track feature.
///
/// Responsibilities:
/// - Store and update track draft data
/// - Handle form inputs (title, artist, genre, etc.)
/// - Manage upload process and progress
/// - Communicate with domain layer via UploadTrackUseCase
/// - Handle success and error states
///
/// Notes:
/// - Uses Riverpod Notifier for state management
/// - Acts as the bridge between UI and business logic

// Manages all state for the upload track screen.
// For now: form state only.
// Upload logic wired in later when backend is confirmed.

// ── Upload form state ──────────────────────────────────────────────────────

class UploadFormState {
  final TrackDraft? draft; // null until audio is picked
  final List<String> availableTags; // fetched from backend
  final List<String> availableGenres;
  final bool isLoading; // true while uploading
  final String? errorMessage; // set when something goes wrong
  final int currentTab; // 0=TrackInfo, 1=Advanced, 2=Permissions

  const UploadFormState({
    this.draft,
    this.availableTags = const [],
    this.availableGenres = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentTab = 0,
  });

  // Has the user filled in everything required to upload?
  bool get canSave =>
      draft != null &&
      draft!.title != null &&
      draft!.title!.trim().isNotEmpty &&
      draft!.artist != null &&
      draft!.artist!.trim().isNotEmpty;

  UploadFormState copyWith({
    TrackDraft? draft,
    List<String>? availableTags,
    List<String>? availableGenres,
    bool? isLoading,
    String? errorMessage,
    int? currentTab,
    bool clearError = false,
  }) {
    return UploadFormState(
      draft: draft ?? this.draft,
      availableTags: availableTags ?? this.availableTags,
      availableGenres: availableGenres ?? this.availableGenres,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      currentTab: currentTab ?? this.currentTab,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────

class UploadFormNotifier extends Notifier<UploadFormState> {
  @override
  UploadFormState build() => const UploadFormState();

  void initFromTrack(track_entity.Track track) {
    state = state.copyWith(
      draft: TrackDraft(
        trackId: track.id,
        remoteArtworkUrl: track.coverImage,
        artistId: track.userId,
        localAudioPath: '', // Not needed for updates
        duration: track.duration,
        title: track.title,
        artist: track.artist,
        genre: track.genre,
        tags: track.tags,
        description: track.description,
        isPublic: track.isPublic,
        isHidden: track.isHidden,
        geoRestrictionType: track.geoRestrictionType ?? 'worldwide',
        geoRegions: track.geoRegions,
        status: UploadStatus.draft,
        audioStatus: UploadStatus.success, // Audio already on server
      ),
    );
  }

  // Replace initDraft with this version that also starts upload
  void initDraft({
    required String artistId,
    required String artistName,
    required String localAudioPath,
    required Duration duration,
    required String fileName,
  }) {
    final nameWithoutExtension = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;

    state = state.copyWith(
      draft: TrackDraft(
        artistId: artistId,
        localAudioPath: localAudioPath,
        duration: duration,
        audioFileName: fileName,
        title: nameWithoutExtension,
        artist: artistName,
        // Start as uploading immediately
        status: UploadStatus.draft,
        uploadProgress: 0.0,
        audioStatus: UploadStatus.uploading, // ← button starts uploading
        audioUploadProgress: 0.0,
      ),
    );
  }

  // Called by the screen right after initDraft
  // Simulates upload for now — replace with real upload later
  void startAudioUpload() async {
    if (state.draft == null) return;

    // Reset audio upload progress
    _updateDraft(
      state.draft!.copyWith(
        audioStatus: UploadStatus.uploading,
        audioUploadProgress: 0.0,
      ),
    );

    // Simulate progress — replace with real upload later
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (state.draft == null) return;
      _updateDraft(
        state.draft!.copyWith(
          audioUploadProgress: i / 10,
          audioStatus: i < 10 ? UploadStatus.uploading : UploadStatus.success,
        ),
      );
    }
  }

  void setTitle(String value) =>
      _updateDraft(state.draft!.copyWith(title: value));

  void setArtist(String value) =>
      _updateDraft(state.draft!.copyWith(artist: value));

  void setGenre(String value) =>
      _updateDraft(state.draft!.copyWith(genre: value));

  void setDescription(String value) =>
      _updateDraft(state.draft!.copyWith(description: value));

  void setCaption(String value) =>
      _updateDraft(state.draft!.copyWith(caption: value));

  void setIsPublic(bool value) =>
      _updateDraft(state.draft!.copyWith(isPublic: value));

  void setIsHidden(bool value) =>
      _updateDraft(state.draft!.copyWith(isHidden: value));

  void setArtwork(String localPath) =>
      _updateDraft(state.draft!.copyWith(localArtworkPath: localPath));

  void removeArtwork() =>
      _updateDraft(state.draft!.copyWith(clearArtwork: true));

  void setGeoRestrictionType(String type) =>
      _updateDraft(state.draft!.copyWith(geoRestrictionType: type));

  void toggleGeoRegion(String region) {
    if (state.draft == null) return;
    final current = List<String>.from(state.draft!.geoRegions);
    if (current.contains(region)) {
      current.remove(region);
    } else {
      current.add(region);
    }
    _updateDraft(state.draft!.copyWith(geoRegions: current));
  }

  void clearGeoRegions() =>
      _updateDraft(state.draft!.copyWith(geoRegions: []));

  void setUploadProgress(double progress) {
    if (state.draft == null) return;
    _updateDraft(
      state.draft!.copyWith(
        uploadProgress: progress,
        status: progress >= 1.0 ? UploadStatus.success : UploadStatus.uploading,
      ),
    );
  }

  //added in backend integration phase
  Future<void> startUpload({
    required WidgetRef ref,
    required void Function(String trackId) onSuccess,
    required void Function(String error) onError,
  }) async {
    final draft = state.draft;
    if (draft == null) return;

    // Set status to uploading
    _updateDraft(
      draft.copyWith(status: UploadStatus.uploading, uploadProgress: 0.0),
    );

    // Get the usecase
    final useCase = ref.read(uploadUseCaseProvider);

    // Call usecase with draft and progress callback
    final result = await useCase(
      draft: draft,
      onProgress: (progress) {
        if (state.draft == null) return;
        _updateDraft(state.draft!.copyWith(uploadProgress: progress));
      },
    );

    // Handle result
    result.fold(
      (failure) {
        if (state.draft == null) return;
        _updateDraft(state.draft!.copyWith(status: UploadStatus.error));
        onError(failure.message);
      },
      (trackId) {
        if (state.draft == null) return;
        _updateDraft(
          state.draft!.copyWith(
            status: UploadStatus.success,
            uploadProgress: 1.0,
          ),
        );
        onSuccess(trackId);
      },
    );
  }

  //added in back integration to fix 400 error when ftetching genres
  Future<void> fetchGenres(WidgetRef ref) async {
    try {
      final dataSource = ref.read(_uploadDataSourceProvider);
      final genres = await dataSource.fetchGenres();
      state = state.copyWith(availableGenres: genres);
      debugPrint('Genres loaded: $genres');
    } catch (e) {
      debugPrint('Failed to load genres: $e');
    }
  }

  Future<void> fetchTags(WidgetRef ref) async {
    try {
      final dataSource = ref.read(_uploadDataSourceProvider);
      final tags = await dataSource.fetchTags();
      state = state.copyWith(availableTags: tags);
      debugPrint('Tags loaded: $tags');
    } catch (e) {
      debugPrint('Failed to load tags: $e');
    }
  }

  void addTag(String tag) {
    if (state.draft == null) return;
    if (state.draft!.tags.contains(tag)) return; // no duplicates
    final updated = List<String>.from(state.draft!.tags)..add(tag);
    _updateDraft(state.draft!.copyWith(tags: updated));
  }

  void removeTag(String tag) {
    if (state.draft == null) return;
    final updated = state.draft!.tags.where((t) => t != tag).toList();
    _updateDraft(state.draft!.copyWith(tags: updated));
  }

  void setTab(int index) => state = state.copyWith(currentTab: index);

  void setAvailableTags(List<String> tags) =>
      state = state.copyWith(availableTags: tags);

  void reset() => state = const UploadFormState();

  // Private helper — updates the draft inside state
  void _updateDraft(TrackDraft updated) {
    state = state.copyWith(draft: updated);
  }

  Future<void> handleUpdate({
    required WidgetRef ref,
    required void Function() onSuccess,
    required void Function(String error) onError,
  }) async {
    final draft = state.draft;
    if (draft == null || draft.trackId == null) return;

    state = state.copyWith(isLoading: true);

    final updateTrack = ref.read(updateTrackUseCaseProvider);

    final Map<String, dynamic> data = {
      "title": draft.title,
      "description": draft.description,
      "genre": draft.genre,
      "tags": draft.tags,
      "artists": draft.artist,
      "cover_image_path": draft.localArtworkPath,
      "is_public": draft.isPublic,
      "is_hidden": draft.isHidden,
      "geo_restriction_type": draft.geoRestrictionType,
      "geo_regions": draft.geoRegions,
    };

    try {
      await updateTrack.call(draft.trackId!, data);
      state = state.copyWith(isLoading: false);
      onSuccess();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      onError(e.toString());
    }
  }

  Future<void> handleDelete({
    required WidgetRef ref,
    required void Function() onSuccess,
    required void Function(String error) onError,
  }) async {
    final draft = state.draft;
    if (draft == null || draft.trackId == null) return;

    state = state.copyWith(isLoading: true);

    final deleteTrack = ref.read(deleteTrackUseCaseProvider);

    try {
      await deleteTrack.call(draft.trackId!);
      state = state.copyWith(isLoading: false);
      onSuccess();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      onError(e.toString());
    }
  }
}

// ── Provider ───────────────────────────────────────────────────────────────

final uploadFormProvider =
    NotifierProvider<UploadFormNotifier, UploadFormState>(
      UploadFormNotifier.new,
    );

// ── Infrastructure providers ───────────────────────────────────────────────
// These wire the datasource → repository → usecase together
// ApiClient handles auth automatically — no token injection needed here

final _uploadDataSourceProvider = Provider<UploadTrackRemoteDataSource>(
  (_) => UploadTrackRemoteDataSource(),
);

final _uploadRepositoryProvider = Provider<UploadTrackRepositoryImpl>(
  (ref) => UploadTrackRepositoryImpl(
    dataSource: ref.watch(_uploadDataSourceProvider),
  ),
);

final uploadUseCaseProvider = Provider<UploadTrackUseCase>(
  (ref) => UploadTrackUseCase(ref.watch(_uploadRepositoryProvider)),
);
