import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/tts_voice.dart';
import '../../domain/entities/tts_settings.dart';
import '../../domain/repositories/tts_repository.dart';
import '../datasources/tts_datasource.dart';
import '../models/tts_settings_model.dart';
import '../models/tts_voice_model.dart';

class TtsRepositoryImpl implements TtsRepository {
  final TtsDataSource dataSource;

  TtsRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      await dataSource.initialize();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error initializing TTS: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TtsVoice>>> getAvailableVoices() async {
    try {
      final voices = await dataSource.getAvailableVoices();
      return Right(voices);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error getting voices: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setVoice(TtsVoice voice) async {
    try {
      final voiceModel = voice is TtsVoiceModel 
          ? voice 
          : TtsVoiceModel.fromEntity(voice);
      await dataSource.setVoice(voiceModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error setting voice: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSettings(TtsSettings settings) async {
    try {
      final settingsModel = settings is TtsSettingsModel 
          ? settings 
          : TtsSettingsModel.fromEntity(settings);
      await dataSource.updateSettings(settingsModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error updating settings: $e'));
    }
  }

  @override
  Future<Either<Failure, TtsSettings>> getSettings() async {
    try {
      final settings = await dataSource.getSettings();
      return Right(settings);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error getting settings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> speak(String text) async {
    try {
      if (text.trim().isEmpty) {
        return Left(CacheFailure('Text cannot be empty'));
      }
      await dataSource.speak(text);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error speaking text: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> pause() async {
    try {
      await dataSource.pause();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error pausing speech: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resume() async {
    try {
      await dataSource.resume();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error resuming speech: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> stop() async {
    try {
      await dataSource.stop();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error stopping speech: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isSpeaking() async {
    try {
      final speaking = await dataSource.isSpeaking();
      return Right(speaking);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error checking speaking status: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setSpeechRate(double rate) async {
    try {
      if (rate < 0.5 || rate > 3.0) {
        return Left(CacheFailure('Speech rate must be between 0.5 and 3.0'));
      }
      await dataSource.setSpeechRate(rate);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error setting speech rate: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setPitch(double pitch) async {
    try {
      if (pitch < 0.5 || pitch > 2.0) {
        return Left(CacheFailure('Pitch must be between 0.5 and 2.0'));
      }
      await dataSource.setPitch(pitch);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error setting pitch: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setVolume(double volume) async {
    try {
      if (volume < 0.0 || volume > 1.0) {
        return Left(CacheFailure('Volume must be between 0.0 and 1.0'));
      }
      await dataSource.setVolume(volume);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error setting volume: $e'));
    }
  }

  @override
  Stream<TtsPlaybackInfo> getPlaybackStream() {
    return dataSource.getPlaybackStream();
  }

  @override
  Stream<Map<String, dynamic>> getWordHighlightStream() {
    return dataSource.getWordHighlightStream();
  }

  @override
  Future<Either<Failure, void>> dispose() async {
    try {
      await dataSource.dispose();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error disposing TTS: $e'));
    }
  }
}