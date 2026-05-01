import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/library_entities.dart';
import '../../../track/presentation/providers/track_dependency_providers.dart';

class DownloadsState extends Equatable {
  final List<DownloadedTrack> tracks;
  final Map<String, double> downloadingProgress; // trackId -> 0.0 to 1.0
  final Map<String, String> downloadErrors; // trackId -> error message
  final bool isLoading;
  final String? error;

  const DownloadsState({
    this.tracks = const [],
    this.downloadingProgress = const {},
    this.downloadErrors = const {},
    this.isLoading = false,
    this.error,
  });

  bool isDownloaded(String trackId) => tracks.any((t) => t.id == trackId);
  double? getProgress(String trackId) => downloadingProgress[trackId];
  String? getDownloadError(String trackId) => downloadErrors[trackId];

  DownloadsState copyWith({
    List<DownloadedTrack>? tracks,
    Map<String, double>? downloadingProgress,
    Map<String, String>? downloadErrors,
    bool? isLoading,
    String? error,
  }) => DownloadsState(
    tracks: tracks ?? this.tracks,
    downloadingProgress: downloadingProgress ?? this.downloadingProgress,
    downloadErrors: downloadErrors ?? this.downloadErrors,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [tracks, downloadingProgress, downloadErrors, isLoading, error];
}

class DownloadsNotifier extends Notifier<DownloadsState> {
  static const _boxName = 'downloads_box';
  static const _key = 'downloaded_tracks';

  @override
  DownloadsState build() {
    // Initial load triggered via build
    Future.microtask(() => _init());
    return const DownloadsState();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      final box = await Hive.openBox(_boxName);
      final rawData = box.get(_key) as List<dynamic>?;
      
      if (rawData != null) {
        final tracks = rawData
            .map((e) => DownloadedTrack.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        state = state.copyWith(tracks: tracks, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _saveToHive() async {
    try {
      final box = await Hive.openBox(_boxName);
      final rawData = state.tracks.map((t) => t.toJson()).toList();
      await box.put(_key, rawData);
    } catch (_) {
      // Log error in production
    }
  }

  Future<void> load() async {
    await _init();
  }

  Future<void> downloadTrack(Track track) async {
    if (state.isDownloaded(track.id)) return;
    if (state.downloadingProgress.containsKey(track.id)) return;

    // Start download
    final progressMap = Map<String, double>.from(state.downloadingProgress);
    progressMap[track.id] = 0.0;
    
    final errorMap = Map<String, String>.from(state.downloadErrors);
    errorMap.remove(track.id);

    state = state.copyWith(
      downloadingProgress: progressMap,
      downloadErrors: errorMap,
    );

    try {
      // 1. Fetch Waveform Data if missing
      List<double>? waveform = track.waveformData;
      if (waveform == null || waveform.isEmpty) {
        try {
          waveform = await ref.read(getWaveformUseCaseProvider).call(track.id);
        } catch (_) {}
      }

      // Simulate progress
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 300));
        
        final currentProgressMap = Map<String, double>.from(state.downloadingProgress);
        currentProgressMap[track.id] = i / 10.0;
        state = state.copyWith(downloadingProgress: currentProgressMap);
      }

      // Complete download
      final completedTrack = DownloadedTrack(
        track: track.copyWith(
          waveformData: waveform,
          likeCount: 0,
          commentCount: 0,
          isLiked: false,
        ),
        localPath: '/mock/path/${track.id}.mp3',
        downloadedAt: DateTime.now(),
      );

      final finalProgressMap = Map<String, double>.from(state.downloadingProgress);
      finalProgressMap.remove(track.id);

      state = state.copyWith(
        tracks: [completedTrack, ...state.tracks],
        downloadingProgress: finalProgressMap,
      );
      
      await _saveToHive();
    } catch (e) {
      final finalProgressMap = Map<String, double>.from(state.downloadingProgress);
      finalProgressMap.remove(track.id);
      
      final finalErrorMap = Map<String, String>.from(state.downloadErrors);
      finalErrorMap[track.id] = e.toString();

      state = state.copyWith(
        downloadingProgress: finalProgressMap,
        downloadErrors: finalErrorMap,
      );
    }
  }

  Future<void> removeTrack(String trackId) async {
    state = state.copyWith(
      tracks: state.tracks.where((t) => t.id != trackId).toList(),
    );
    await _saveToHive();
  }
}

final downloadsProvider = NotifierProvider<DownloadsNotifier, DownloadsState>(
  () => DownloadsNotifier(),
);
