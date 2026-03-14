
// Manages all state for the upload track screen.
// For now: form state only.
// Upload logic wired in later when backend is confirmed.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/track_draft.dart';

// ── Upload form state ──────────────────────────────────────────────────────

class UploadFormState {
  final TrackDraft? draft;          // null until audio is picked
  final List<String> availableTags; // fetched from backend
  final bool isLoading;             // true while uploading
  final String? errorMessage;       // set when something goes wrong
  final int currentTab;             // 0=TrackInfo, 1=Advanced, 2=Permissions

  const UploadFormState({
    this.draft,
    this.availableTags = const [],
    this.isLoading     = false,
    this.errorMessage,
    this.currentTab    = 0,
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
      draft:         draft         ?? this.draft,
      availableTags: availableTags ?? this.availableTags,
      isLoading:     isLoading     ?? this.isLoading,
      errorMessage:  clearError ? null : errorMessage ?? this.errorMessage,
      currentTab:    currentTab    ?? this.currentTab,
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
    state = state.copyWith(
      draft: TrackDraft(
        artistId:       artistId,
        localAudioPath: localAudioPath,
        duration:       duration,
      ),
    );
  }

  // Form field updates
  void setTitle(String value) => _updateDraft(
    state.draft!.copyWith(title: value),
  );

  void setArtist(String value) => _updateDraft(
    state.draft!.copyWith(artist: value),
  );

  void setGenre(String value) => _updateDraft(
    state.draft!.copyWith(genre: value),
  );

  void setDescription(String value) => _updateDraft(
    state.draft!.copyWith(description: value),
  );

  void setCaption(String value) => _updateDraft(
    state.draft!.copyWith(caption: value),
  );

  void setIsPublic(bool value) => _updateDraft(
    state.draft!.copyWith(isPublic: value),
  );

  void setArtwork(String localPath) => _updateDraft(
    state.draft!.copyWith(localArtworkPath: localPath),
  );

  void removeArtwork() => _updateDraft(
    state.draft!.copyWith(clearArtwork: true),
  );

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