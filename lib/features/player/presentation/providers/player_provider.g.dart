// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(audioRepository)
final audioRepositoryProvider = AudioRepositoryProvider._();

final class AudioRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<AudioRepository>,
          AudioRepository,
          FutureOr<AudioRepository>
        >
    with $FutureModifier<AudioRepository>, $FutureProvider<AudioRepository> {
  AudioRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<AudioRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AudioRepository> create(Ref ref) {
    return audioRepository(ref);
  }
}

String _$audioRepositoryHash() => r'2a6c21bedf82004d61d87d07cb89033b266782e0';

@ProviderFor(PlayerStateNotifier)
final playerStateProvider = PlayerStateNotifierProvider._();

final class PlayerStateNotifierProvider
    extends $NotifierProvider<PlayerStateNotifier, AppPlayerState> {
  PlayerStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerStateNotifierHash();

  @$internal
  @override
  PlayerStateNotifier create() => PlayerStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppPlayerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppPlayerState>(value),
    );
  }
}

String _$playerStateNotifierHash() =>
    r'98ae35987ca836752a8aca564c0179be6062ba9a';

abstract class _$PlayerStateNotifier extends $Notifier<AppPlayerState> {
  AppPlayerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppPlayerState, AppPlayerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppPlayerState, AppPlayerState>,
              AppPlayerState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(QueueNotifier)
final queueProvider = QueueNotifierProvider._();

final class QueueNotifierProvider
    extends $NotifierProvider<QueueNotifier, List<TrackSummary>> {
  QueueNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'queueProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$queueNotifierHash();

  @$internal
  @override
  QueueNotifier create() => QueueNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TrackSummary> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TrackSummary>>(value),
    );
  }
}

String _$queueNotifierHash() => r'5ccac6d996f338cdbbad310d8c35dee70a9e5bac';

abstract class _$QueueNotifier extends $Notifier<List<TrackSummary>> {
  List<TrackSummary> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<TrackSummary>, List<TrackSummary>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<TrackSummary>, List<TrackSummary>>,
              List<TrackSummary>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
