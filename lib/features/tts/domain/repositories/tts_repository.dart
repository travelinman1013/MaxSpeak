import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/tts_voice.dart';
import '../entities/tts_settings.dart';

abstract class TtsRepository {
  /// Initialize TTS engine
  Future<Either<Failure, void>> initialize();
  
  /// Get available voices
  Future<Either<Failure, List<TtsVoice>>> getAvailableVoices();
  
  /// Set voice for TTS
  Future<Either<Failure, void>> setVoice(TtsVoice voice);
  
  /// Update TTS settings
  Future<Either<Failure, void>> updateSettings(TtsSettings settings);
  
  /// Get current TTS settings
  Future<Either<Failure, TtsSettings>> getSettings();
  
  /// Speak text
  Future<Either<Failure, void>> speak(String text);
  
  /// Pause speech
  Future<Either<Failure, void>> pause();
  
  /// Resume speech
  Future<Either<Failure, void>> resume();
  
  /// Stop speech
  Future<Either<Failure, void>> stop();
  
  /// Check if TTS is speaking
  Future<Either<Failure, bool>> isSpeaking();
  
  /// Set speech rate (0.5 to 3.0)
  Future<Either<Failure, void>> setSpeechRate(double rate);
  
  /// Set pitch (0.5 to 2.0)
  Future<Either<Failure, void>> setPitch(double pitch);
  
  /// Set volume (0.0 to 1.0)
  Future<Either<Failure, void>> setVolume(double volume);
  
  /// Get playback info stream
  Stream<TtsPlaybackInfo> getPlaybackStream();
  
  /// Get word highlighting stream (word index and bounds)
  Stream<Map<String, dynamic>> getWordHighlightStream();
  
  /// Dispose TTS engine
  Future<Either<Failure, void>> dispose();
}