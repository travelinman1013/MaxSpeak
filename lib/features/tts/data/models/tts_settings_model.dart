import 'package:hive/hive.dart';
import '../../domain/entities/tts_settings.dart';
import 'tts_voice_model.dart';

part 'tts_settings_model.g.dart';

@HiveType(typeId: 6)
class TtsSettingsModel extends TtsSettings {
  @HiveField(0)
  final TtsVoiceModel? selectedVoice;
  
  @HiveField(1)
  final double speechRate;
  
  @HiveField(2)
  final double pitch;
  
  @HiveField(3)
  final double volume;
  
  @HiveField(4)
  final bool autoScroll;
  
  @HiveField(5)
  final bool highlightWords;
  
  @HiveField(6)
  final bool pauseOnPhoneCalls;
  
  @HiveField(7)
  final bool enableBackgroundPlayback;
  
  @HiveField(8)
  final int skipSeconds;

  const TtsSettingsModel({
    this.selectedVoice,
    this.speechRate = 1.0,
    this.pitch = 1.0,
    this.volume = 0.8,
    this.autoScroll = true,
    this.highlightWords = true,
    this.pauseOnPhoneCalls = true,
    this.enableBackgroundPlayback = true,
    this.skipSeconds = 10,
  }) : super(
    selectedVoice: selectedVoice,
    speechRate: speechRate,
    pitch: pitch,
    volume: volume,
    autoScroll: autoScroll,
    highlightWords: highlightWords,
    pauseOnPhoneCalls: pauseOnPhoneCalls,
    enableBackgroundPlayback: enableBackgroundPlayback,
    skipSeconds: skipSeconds,
  );

  factory TtsSettingsModel.fromEntity(TtsSettings settings) {
    return TtsSettingsModel(
      selectedVoice: settings.selectedVoice != null 
          ? TtsVoiceModel.fromEntity(settings.selectedVoice!)
          : null,
      speechRate: settings.speechRate,
      pitch: settings.pitch,
      volume: settings.volume,
      autoScroll: settings.autoScroll,
      highlightWords: settings.highlightWords,
      pauseOnPhoneCalls: settings.pauseOnPhoneCalls,
      enableBackgroundPlayback: settings.enableBackgroundPlayback,
      skipSeconds: settings.skipSeconds,
    );
  }

  factory TtsSettingsModel.fromJson(Map<String, dynamic> json) {
    return TtsSettingsModel(
      selectedVoice: json['selectedVoice'] != null 
          ? TtsVoiceModel.fromJson(json['selectedVoice'] as Map<String, dynamic>)
          : null,
      speechRate: json['speechRate'] as double? ?? 1.0,
      pitch: json['pitch'] as double? ?? 1.0,
      volume: json['volume'] as double? ?? 0.8,
      autoScroll: json['autoScroll'] as bool? ?? true,
      highlightWords: json['highlightWords'] as bool? ?? true,
      pauseOnPhoneCalls: json['pauseOnPhoneCalls'] as bool? ?? true,
      enableBackgroundPlayback: json['enableBackgroundPlayback'] as bool? ?? true,
      skipSeconds: json['skipSeconds'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedVoice': selectedVoice?.toJson(),
      'speechRate': speechRate,
      'pitch': pitch,
      'volume': volume,
      'autoScroll': autoScroll,
      'highlightWords': highlightWords,
      'pauseOnPhoneCalls': pauseOnPhoneCalls,
      'enableBackgroundPlayback': enableBackgroundPlayback,
      'skipSeconds': skipSeconds,
    };
  }

  @override
  TtsSettingsModel copyWith({
    covariant TtsVoiceModel? selectedVoice,
    double? speechRate,
    double? pitch,
    double? volume,
    bool? autoScroll,
    bool? highlightWords,
    bool? pauseOnPhoneCalls,
    bool? enableBackgroundPlayback,
    int? skipSeconds,
  }) {
    return TtsSettingsModel(
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
}

@HiveType(typeId: 7)
class TtsPlaybackInfoModel extends TtsPlaybackInfo {
  @HiveField(0)
  final TtsPlaybackState state;
  
  @HiveField(1)
  final String? currentText;
  
  @HiveField(2)
  final int currentWordIndex;
  
  @HiveField(3)
  final int totalWords;
  
  @HiveField(4)
  final Duration currentPosition;
  
  @HiveField(5)
  final Duration totalDuration;
  
  @HiveField(6)
  final String? error;

  const TtsPlaybackInfoModel({
    this.state = TtsPlaybackState.stopped,
    this.currentText,
    this.currentWordIndex = 0,
    this.totalWords = 0,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.error,
  }) : super(
    state: state,
    currentText: currentText,
    currentWordIndex: currentWordIndex,
    totalWords: totalWords,
    currentPosition: currentPosition,
    totalDuration: totalDuration,
    error: error,
  );

  factory TtsPlaybackInfoModel.fromEntity(TtsPlaybackInfo info) {
    return TtsPlaybackInfoModel(
      state: info.state,
      currentText: info.currentText,
      currentWordIndex: info.currentWordIndex,
      totalWords: info.totalWords,
      currentPosition: info.currentPosition,
      totalDuration: info.totalDuration,
      error: info.error,
    );
  }

  TtsPlaybackInfoModel copyWith({
    TtsPlaybackState? state,
    String? currentText,
    int? currentWordIndex,
    int? totalWords,
    Duration? currentPosition,
    Duration? totalDuration,
    String? error,
  }) {
    return TtsPlaybackInfoModel(
      state: state ?? this.state,
      currentText: currentText ?? this.currentText,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
      totalWords: totalWords ?? this.totalWords,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      error: error ?? this.error,
    );
  }
}