import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/tts_voice_model.dart';
import '../models/tts_settings_model.dart';
import '../../domain/entities/tts_settings.dart';

abstract class TtsDataSource {
  Future<void> initialize();
  Future<List<TtsVoiceModel>> getAvailableVoices();
  Future<void> setVoice(TtsVoiceModel voice);
  Future<void> updateSettings(TtsSettingsModel settings);
  Future<TtsSettingsModel> getSettings();
  Future<void> speak(String text);
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<bool> isSpeaking();
  Future<void> setSpeechRate(double rate);
  Future<void> setPitch(double pitch);
  Future<void> setVolume(double volume);
  Stream<TtsPlaybackInfoModel> getPlaybackStream();
  Stream<Map<String, dynamic>> getWordHighlightStream();
  Future<void> dispose();
}

class TtsDataSourceImpl implements TtsDataSource {
  late FlutterTts _flutterTts;
  late StreamController<TtsPlaybackInfoModel> _playbackController;
  late StreamController<Map<String, dynamic>> _wordHighlightController;
  
  TtsSettingsModel _currentSettings = const TtsSettingsModel();
  TtsPlaybackInfoModel _currentPlaybackInfo = const TtsPlaybackInfoModel();
  String? _currentText;
  List<String> _currentWords = [];
  int _currentWordIndex = 0;

  @override
  Future<void> initialize() async {
    try {
      _flutterTts = FlutterTts();
      _playbackController = StreamController<TtsPlaybackInfoModel>.broadcast();
      _wordHighlightController = StreamController<Map<String, dynamic>>.broadcast();

      // Set up event handlers
      await _setupEventHandlers();

      // Configure TTS
      await _configureTts();

      if (kDebugMode) {
        print('TTS engine initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing TTS: $e');
      }
      throw CacheException('Failed to initialize TTS engine: $e');
    }
  }

  Future<void> _setupEventHandlers() async {
    _flutterTts.setStartHandler(() {
      _updatePlaybackInfo(_currentPlaybackInfo.copyWith(
        state: TtsPlaybackState.playing,
      ));
    });

    _flutterTts.setCompletionHandler(() {
      _updatePlaybackInfo(_currentPlaybackInfo.copyWith(
        state: TtsPlaybackState.stopped,
        currentWordIndex: 0,
      ));
    });

    _flutterTts.setErrorHandler((message) {
      _updatePlaybackInfo(_currentPlaybackInfo.copyWith(
        state: TtsPlaybackState.error,
        error: message,
      ));
    });

    _flutterTts.setPauseHandler(() {
      _updatePlaybackInfo(_currentPlaybackInfo.copyWith(
        state: TtsPlaybackState.paused,
      ));
    });

    _flutterTts.setContinueHandler(() {
      _updatePlaybackInfo(_currentPlaybackInfo.copyWith(
        state: TtsPlaybackState.playing,
      ));
    });

    // Word highlighting (if supported by platform)
    if (Platform.isIOS) {
      _flutterTts.setProgressHandler((String text, int start, int end, String word) {
        _handleWordProgress(text, start, end, word);
      });
    }
  }

  Future<void> _configureTts() async {
    // Set default language
    await _flutterTts.setLanguage('en-US');
    
    // Set default settings
    await _flutterTts.setSpeechRate(_currentSettings.speechRate);
    await _flutterTts.setPitch(_currentSettings.pitch);
    await _flutterTts.setVolume(_currentSettings.volume);

    // Configure for mobile
    if (Platform.isIOS) {
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [IosTextToSpeechAudioCategoryOptions.allowBluetooth],
        IosTextToSpeechAudioMode.defaultMode,
      );
    }
  }

  void _handleWordProgress(String text, int start, int end, String word) {
    // Find word index in our word list
    final wordIndex = _findWordIndex(word, start);
    
    if (wordIndex != -1) {
      _currentWordIndex = wordIndex;
      
      _updatePlaybackInfo(_currentPlaybackInfo.copyWith(
        currentWordIndex: wordIndex,
      ));

      // Emit word highlighting info
      _wordHighlightController.add({
        'wordIndex': wordIndex,
        'word': word,
        'startOffset': start,
        'endOffset': end,
        'progress': wordIndex / _currentWords.length,
      });
    }
  }

  int _findWordIndex(String word, int startOffset) {
    // Simple word matching - can be improved
    for (int i = 0; i < _currentWords.length; i++) {
      if (_currentWords[i].toLowerCase() == word.toLowerCase()) {
        return i;
      }
    }
    return -1;
  }

  void _updatePlaybackInfo(TtsPlaybackInfoModel info) {
    _currentPlaybackInfo = info;
    _playbackController.add(info);
  }

  @override
  Future<List<TtsVoiceModel>> getAvailableVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      
      if (voices == null || voices.isEmpty) {
        return [];
      }

      return voices.map<TtsVoiceModel>((voice) {
        final voiceMap = voice as Map<String, dynamic>;
        return TtsVoiceModel(
          id: voiceMap['name'] ?? 'unknown',
          name: voiceMap['name'] ?? 'Unknown Voice',
          language: voiceMap['locale'] ?? 'en-US',
          locale: voiceMap['locale'] ?? 'en-US',
          isLocal: true,
          gender: _inferGender(voiceMap['name'] ?? ''),
          quality: 3, // Default quality
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting voices: $e');
      }
      throw CacheException('Failed to get available voices: $e');
    }
  }

  String? _inferGender(String voiceName) {
    final name = voiceName.toLowerCase();
    if (name.contains('female') || name.contains('woman') || 
        name.contains('samantha') || name.contains('alex') ||
        name.contains('karen') || name.contains('moira')) {
      return 'female';
    } else if (name.contains('male') || name.contains('man') ||
               name.contains('daniel') || name.contains('tom') ||
               name.contains('aaron')) {
      return 'male';
    }
    return null;
  }

  @override
  Future<void> setVoice(TtsVoiceModel voice) async {
    try {
      await _flutterTts.setVoice({'name': voice.id, 'locale': voice.locale});
      
      _currentSettings = _currentSettings.copyWith(selectedVoice: voice);
      
      if (kDebugMode) {
        print('Voice set to: ${voice.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting voice: $e');
      }
      throw CacheException('Failed to set voice: $e');
    }
  }

  @override
  Future<void> updateSettings(TtsSettingsModel settings) async {
    try {
      await setSpeechRate(settings.speechRate);
      await setPitch(settings.pitch);
      await setVolume(settings.volume);
      
      if (settings.selectedVoice != null) {
        await setVoice(settings.selectedVoice!);
      }
      
      _currentSettings = settings;
      
      if (kDebugMode) {
        print('TTS settings updated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating settings: $e');
      }
      throw CacheException('Failed to update TTS settings: $e');
    }
  }

  @override
  Future<TtsSettingsModel> getSettings() async {
    return _currentSettings;
  }

  @override
  Future<void> speak(String text) async {
    try {
      _currentText = text;
      _currentWords = text.trim().split(RegExp(r'\s+'));
      _currentWordIndex = 0;
      
      _updatePlaybackInfo(TtsPlaybackInfoModel(
        state: TtsPlaybackState.loading,
        currentText: text,
        totalWords: _currentWords.length,
      ));

      await _flutterTts.speak(text);
      
      if (kDebugMode) {
        print('Speaking text: ${text.substring(0, text.length.clamp(0, 50))}...');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error speaking text: $e');
      }
      _updatePlaybackInfo(_currentPlaybackInfo.copyWith(
        state: TtsPlaybackState.error,
        error: e.toString(),
      ));
      throw CacheException('Failed to speak text: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      if (kDebugMode) {
        print('Error pausing speech: $e');
      }
      throw CacheException('Failed to pause speech: $e');
    }
  }

  @override
  Future<void> resume() async {
    try {
      // Note: flutter_tts doesn't have resume, so we need to continue from where we left off
      // This is a limitation that would need to be addressed in a production app
      await _flutterTts.speak(_currentText ?? '');
    } catch (e) {
      if (kDebugMode) {
        print('Error resuming speech: $e');
      }
      throw CacheException('Failed to resume speech: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _currentWordIndex = 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping speech: $e');
      }
      throw CacheException('Failed to stop speech: $e');
    }
  }

  @override
  Future<bool> isSpeaking() async {
    try {
      return await _flutterTts.isLanguageAvailable(_currentSettings.selectedVoice?.locale ?? 'en-US') ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking speaking status: $e');
      }
      return false;
    }
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate);
      _currentSettings = _currentSettings.copyWith(speechRate: rate);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting speech rate: $e');
      }
      throw CacheException('Failed to set speech rate: $e');
    }
  }

  @override
  Future<void> setPitch(double pitch) async {
    try {
      await _flutterTts.setPitch(pitch);
      _currentSettings = _currentSettings.copyWith(pitch: pitch);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting pitch: $e');
      }
      throw CacheException('Failed to set pitch: $e');
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    try {
      await _flutterTts.setVolume(volume);
      _currentSettings = _currentSettings.copyWith(volume: volume);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting volume: $e');
      }
      throw CacheException('Failed to set volume: $e');
    }
  }

  @override
  Stream<TtsPlaybackInfoModel> getPlaybackStream() {
    return _playbackController.stream;
  }

  @override
  Stream<Map<String, dynamic>> getWordHighlightStream() {
    return _wordHighlightController.stream;
  }

  @override
  Future<void> dispose() async {
    try {
      await _flutterTts.stop();
      await _playbackController.close();
      await _wordHighlightController.close();
      
      if (kDebugMode) {
        print('TTS engine disposed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error disposing TTS: $e');
      }
    }
  }
}