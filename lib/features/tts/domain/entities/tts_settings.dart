import 'package:equatable/equatable.dart';
import 'tts_voice.dart';

enum TtsPlaybackState {
  stopped,
  playing,
  paused,
  loading,
  error,
}

class TtsSettings extends Equatable {
  final TtsVoice? selectedVoice;
  final double speechRate; // 0.5 to 3.0
  final double pitch; // 0.5 to 2.0
  final double volume; // 0.0 to 1.0
  final bool autoScroll;
  final bool highlightWords;
  final bool pauseOnPhoneCalls;
  final bool enableBackgroundPlayback;
  final int skipSeconds; // Forward/backward skip duration

  const TtsSettings({
    this.selectedVoice,
    this.speechRate = 1.0,
    this.pitch = 1.0,
    this.volume = 0.8,
    this.autoScroll = true,
    this.highlightWords = true,
    this.pauseOnPhoneCalls = true,
    this.enableBackgroundPlayback = true,
    this.skipSeconds = 10,
  });

  TtsSettings copyWith({
    TtsVoice? selectedVoice,
    double? speechRate,
    double? pitch,
    double? volume,
    bool? autoScroll,
    bool? highlightWords,
    bool? pauseOnPhoneCalls,
    bool? enableBackgroundPlayback,
    int? skipSeconds,
  }) {
    return TtsSettings(
      selectedVoice: selectedVoice ?? this.selectedVoice,
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
      autoScroll: autoScroll ?? this.autoScroll,
      highlightWords: highlightWords ?? this.highlightWords,
      pauseOnPhoneCalls: pauseOnPhoneCalls ?? this.pauseOnPhoneCalls,
      enableBackgroundPlayback: enableBackgroundPlayback ?? this.enableBackgroundPlayback,
      skipSeconds: skipSeconds ?? this.skipSeconds,
    );
  }

  // Get speech rate as percentage
  String get speechRatePercentage => '${(speechRate * 100).toInt()}%';
  
  // Get pitch as descriptive string
  String get pitchDescription {
    if (pitch < 0.8) return 'Low';
    if (pitch > 1.2) return 'High';
    return 'Normal';
  }

  // Validate settings
  bool get isValid {
    return speechRate >= 0.5 && speechRate <= 3.0 &&
           pitch >= 0.5 && pitch <= 2.0 &&
           volume >= 0.0 && volume <= 1.0 &&
           skipSeconds > 0 && skipSeconds <= 60;
  }

  @override
  List<Object?> get props => [
    selectedVoice,
    speechRate,
    pitch,
    volume,
    autoScroll,
    highlightWords,
    pauseOnPhoneCalls,
    enableBackgroundPlayback,
    skipSeconds,
  ];
}

class TtsPlaybackInfo extends Equatable {
  final TtsPlaybackState state;
  final String? currentText;
  final int currentWordIndex;
  final int totalWords;
  final Duration currentPosition;
  final Duration totalDuration;
  final String? error;

  const TtsPlaybackInfo({
    this.state = TtsPlaybackState.stopped,
    this.currentText,
    this.currentWordIndex = 0,
    this.totalWords = 0,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.error,
  });

  TtsPlaybackInfo copyWith({
    TtsPlaybackState? state,
    String? currentText,
    int? currentWordIndex,
    int? totalWords,
    Duration? currentPosition,
    Duration? totalDuration,
    String? error,
  }) {
    return TtsPlaybackInfo(
      state: state ?? this.state,
      currentText: currentText ?? this.currentText,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
      totalWords: totalWords ?? this.totalWords,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      error: error ?? this.error,
    );
  }

  bool get isPlaying => state == TtsPlaybackState.playing;
  bool get isPaused => state == TtsPlaybackState.paused;
  bool get isStopped => state == TtsPlaybackState.stopped;
  bool get isLoading => state == TtsPlaybackState.loading;
  bool get hasError => state == TtsPlaybackState.error && error != null;
  
  double get progress {
    if (totalWords == 0) return 0.0;
    return currentWordIndex / totalWords;
  }

  String get progressText => '$currentWordIndex / $totalWords words';

  @override
  List<Object?> get props => [
    state,
    currentText,
    currentWordIndex,
    totalWords,
    currentPosition,
    totalDuration,
    error,
  ];
}