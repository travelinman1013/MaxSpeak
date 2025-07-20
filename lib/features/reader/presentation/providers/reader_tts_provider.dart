import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../tts/domain/entities/tts_settings.dart';
import '../../../tts/domain/entities/tts_voice.dart';
import '../../../tts/domain/usecases/manage_tts_playback.dart';
import '../../../tts/domain/usecases/manage_tts_settings.dart';
import '../../../../core/usecases/usecase.dart' show UseCase, NoParams;
import '../../../tts/data/datasources/tts_datasource.dart';
import '../../../tts/data/repositories/tts_repository_impl.dart';
import '../../domain/entities/text_selection.dart' as domain;

// TTS data source provider
final readerTtsDataSourceProvider = Provider<TtsDataSourceImpl>((ref) {
  return TtsDataSourceImpl();
});

// TTS repository provider
final readerTtsRepositoryProvider = Provider<TtsRepositoryImpl>((ref) {
  final dataSource = ref.watch(readerTtsDataSourceProvider);
  return TtsRepositoryImpl(dataSource: dataSource);
});

// TTS use case providers
final speakTextProvider = Provider<SpeakText>((ref) {
  final repository = ref.watch(readerTtsRepositoryProvider);
  return SpeakText(repository);
});

final pauseSpeechProvider = Provider<PauseSpeech>((ref) {
  final repository = ref.watch(readerTtsRepositoryProvider);
  return PauseSpeech(repository);
});

final resumeSpeechProvider = Provider<ResumeSpeech>((ref) {
  final repository = ref.watch(readerTtsRepositoryProvider);
  return ResumeSpeech(repository);
});

final stopSpeechProvider = Provider<StopSpeech>((ref) {
  final repository = ref.watch(readerTtsRepositoryProvider);
  return StopSpeech(repository);
});

final getTtsSettingsProvider = Provider<GetTtsSettings>((ref) {
  final repository = ref.watch(readerTtsRepositoryProvider);
  return GetTtsSettings(repository);
});

final updateTtsSettingsProvider = Provider<UpdateTtsSettings>((ref) {
  final repository = ref.watch(readerTtsRepositoryProvider);
  return UpdateTtsSettings(repository);
});

final getAvailableVoicesProvider = Provider<GetAvailableVoices>((ref) {
  final repository = ref.watch(readerTtsRepositoryProvider);
  return GetAvailableVoices(repository);
});

// Reader TTS State
class ReaderTtsState {
  final bool isInitialized;
  final TtsPlaybackState playbackState;
  final TtsSettings settings;
  final List<TtsVoice> availableVoices;
  final String? currentText;
  final int currentWordIndex;
  final int totalWords;
  final String? error;
  final bool isLoading;

  const ReaderTtsState({
    this.isInitialized = false,
    this.playbackState = TtsPlaybackState.stopped,
    this.settings = const TtsSettings(),
    this.availableVoices = const [],
    this.currentText,
    this.currentWordIndex = 0,
    this.totalWords = 0,
    this.error,
    this.isLoading = false,
  });

  ReaderTtsState copyWith({
    bool? isInitialized,
    TtsPlaybackState? playbackState,
    TtsSettings? settings,
    List<TtsVoice>? availableVoices,
    String? currentText,
    int? currentWordIndex,
    int? totalWords,
    String? error,
    bool? isLoading,
  }) {
    return ReaderTtsState(
      isInitialized: isInitialized ?? this.isInitialized,
      playbackState: playbackState ?? this.playbackState,
      settings: settings ?? this.settings,
      availableVoices: availableVoices ?? this.availableVoices,
      currentText: currentText ?? this.currentText,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
      totalWords: totalWords ?? this.totalWords,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isPlaying => playbackState == TtsPlaybackState.playing;
  bool get isPaused => playbackState == TtsPlaybackState.paused;
  bool get isStopped => playbackState == TtsPlaybackState.stopped;
  bool get hasError => error != null;
  
  double get progress {
    if (totalWords == 0) return 0.0;
    return currentWordIndex / totalWords;
  }

  String get playbackStatus {
    switch (playbackState) {
      case TtsPlaybackState.playing:
        return 'Playing';
      case TtsPlaybackState.paused:
        return 'Paused';
      case TtsPlaybackState.loading:
        return 'Loading...';
      case TtsPlaybackState.error:
        return 'Error';
      case TtsPlaybackState.stopped:
      default:
        return 'Stopped';
    }
  }
}

// Reader TTS Notifier
class ReaderTtsNotifier extends StateNotifier<ReaderTtsState> {
  final SpeakText _speakText;
  final PauseSpeech _pauseSpeech;
  final ResumeSpeech _resumeSpeech;
  final StopSpeech _stopSpeech;
  final GetTtsSettings _getTtsSettings;
  final UpdateTtsSettings _updateTtsSettings;
  final GetAvailableVoices _getAvailableVoices;
  final TtsDataSourceImpl _dataSource;

  ReaderTtsNotifier(
    this._speakText,
    this._pauseSpeech,
    this._resumeSpeech,
    this._stopSpeech,
    this._getTtsSettings,
    this._updateTtsSettings,
    this._getAvailableVoices,
    this._dataSource,
  ) : super(const ReaderTtsState());

  Future<void> initialize() async {
    if (state.isInitialized) return;

    state = state.copyWith(isLoading: true);

    try {
      // Initialize TTS data source
      await _dataSource.initialize();

      // Load settings
      final settingsResult = await _getTtsSettings(const NoParams());
      TtsSettings loadedSettings = const TtsSettings();
      settingsResult.fold(
        (failure) => print('Failed to load TTS settings: ${failure.message}'),
        (settings) => loadedSettings = settings,
      );

      // Load available voices
      final voicesResult = await _getAvailableVoices(const NoParams());
      List<TtsVoice> voices = [];
      voicesResult.fold(
        (failure) => print('Failed to load voices: ${failure.message}'),
        (availableVoices) => voices = availableVoices,
      );

      // Listen to playback stream
      _dataSource.getPlaybackStream().listen((playbackInfo) {
        if (mounted) {
          state = state.copyWith(
            playbackState: playbackInfo.state,
            currentWordIndex: playbackInfo.currentWordIndex,
            totalWords: playbackInfo.totalWords,
            error: playbackInfo.error,
          );
        }
      });

      state = state.copyWith(
        isInitialized: true,
        isLoading: false,
        settings: loadedSettings,
        availableVoices: voices,
        error: null,
      );

      if (kDebugMode) {
        print('Reader TTS initialized successfully');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize TTS: $e',
      );
      
      if (kDebugMode) {
        print('Error initializing Reader TTS: $e');
      }
    }
  }

  Future<void> speakSelection(domain.TextSelection selection) async {
    if (!state.isInitialized) {
      await initialize();
    }

    state = state.copyWith(
      isLoading: true,
      currentText: selection.selectedText,
      error: null,
    );

    final result = await _speakText(selection.selectedText);
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          playbackState: TtsPlaybackState.error,
        );
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          playbackState: TtsPlaybackState.playing,
        );
      },
    );
  }

  Future<void> speakText(String text) async {
    if (!state.isInitialized) {
      await initialize();
    }

    state = state.copyWith(
      isLoading: true,
      currentText: text,
      error: null,
    );

    final result = await _speakText(text);
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          playbackState: TtsPlaybackState.error,
        );
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          playbackState: TtsPlaybackState.playing,
        );
      },
    );
  }

  Future<void> pause() async {
    final result = await _pauseSpeech(const NoParams());
    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (_) {
        state = state.copyWith(playbackState: TtsPlaybackState.paused);
      },
    );
  }

  Future<void> resume() async {
    final result = await _resumeSpeech(const NoParams());
    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (_) {
        state = state.copyWith(playbackState: TtsPlaybackState.playing);
      },
    );
  }

  Future<void> stop() async {
    final result = await _stopSpeech(const NoParams());
    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (_) {
        state = state.copyWith(
          playbackState: TtsPlaybackState.stopped,
          currentWordIndex: 0,
          currentText: null,
        );
      },
    );
  }

  Future<void> updateSettings(TtsSettings newSettings) async {
    final result = await _updateTtsSettings(newSettings);
    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (_) {
        state = state.copyWith(settings: newSettings);
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _dataSource.dispose();
    super.dispose();
  }
}

// Reader TTS Provider
final readerTtsProvider = StateNotifierProvider<ReaderTtsNotifier, ReaderTtsState>((ref) {
  final speakText = ref.watch(speakTextProvider);
  final pauseSpeech = ref.watch(pauseSpeechProvider);
  final resumeSpeech = ref.watch(resumeSpeechProvider);
  final stopSpeech = ref.watch(stopSpeechProvider);
  final getTtsSettings = ref.watch(getTtsSettingsProvider);
  final updateTtsSettings = ref.watch(updateTtsSettingsProvider);
  final getAvailableVoices = ref.watch(getAvailableVoicesProvider);
  final dataSource = ref.watch(readerTtsDataSourceProvider);

  return ReaderTtsNotifier(
    speakText,
    pauseSpeech,
    resumeSpeech,
    stopSpeech,
    getTtsSettings,
    updateTtsSettings,
    getAvailableVoices,
    dataSource,
  );
});