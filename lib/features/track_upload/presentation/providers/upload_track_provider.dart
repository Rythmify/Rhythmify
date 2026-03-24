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

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/track_upload/data/datasources/upload_track_remote_datasource.dart';
import 'package:rythmify/features/track_upload/data/repositories/upload_track_repository_impl.dart';
import 'package:rythmify/features/track_upload/domain/entities/track_draft.dart';
import 'package:rythmify/features/track_upload/domain/usecases/upload_track_usecase.dart';

// ── Upload form state ──────────────────────────────────────────────────────

class UploadFormState {
  final TrackDraft? draft; // null until audio is picked
  final List<String> availableTags; // fetched from backend
  final bool isLoading; // true while uploading
  final String? errorMessage; // set when something goes wrong
  final int currentTab; // 0=TrackInfo, 1=Advanced, 2=Permissions

  const UploadFormState({
    this.draft,
    this.availableTags = const [],
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
    bool? isLoading,
    String? errorMessage,
    int? currentTab,
    bool clearError = false,
  }) {
    return UploadFormState(
      draft: draft ?? this.draft,
      availableTags: availableTags ?? this.availableTags,
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

  // Called when user picks audio file
  void initDraft({
    required String artistId,
    required String localAudioPath,
    required Duration duration,
    required String fileName,
  }) {
    // Remove file extension for title pre-fill
    // "summer_vibes.mp3" → "summer_vibes"
    final nameWithoutExtension = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;

    state = state.copyWith(
      draft: TrackDraft(
        artistId: artistId,
        localAudioPath: localAudioPath,
        duration: duration,
        audioFileName: fileName, // store original filename
        title: nameWithoutExtension, // pre-filled
        artist: 'Your Name', // replace with real username when auth ready
      ),
    );
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

  void setArtwork(String localPath) =>
      _updateDraft(state.draft!.copyWith(localArtworkPath: localPath));

  void removeArtwork() =>
      _updateDraft(state.draft!.copyWith(clearArtwork: true));

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
