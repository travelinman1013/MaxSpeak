import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/tts_voice.dart';
import '../entities/tts_settings.dart';
import '../repositories/tts_repository.dart';

class GetAvailableVoices implements UseCase<List<TtsVoice>, NoParams> {
  final TtsRepository repository;

  GetAvailableVoices(this.repository);

  @override
  Future<Either<Failure, List<TtsVoice>>> call(NoParams params) async {
    return await repository.getAvailableVoices();
  }
}

class SetTtsVoice implements UseCase<void, TtsVoice> {
  final TtsRepository repository;

  SetTtsVoice(this.repository);

  @override
  Future<Either<Failure, void>> call(TtsVoice voice) async {
    return await repository.setVoice(voice);
  }
}

class UpdateTtsSettings implements UseCase<void, TtsSettings> {
  final TtsRepository repository;

  UpdateTtsSettings(this.repository);

  @override
  Future<Either<Failure, void>> call(TtsSettings settings) async {
    if (!settings.isValid) {
      return Left(InvalidSettingsFailure('Invalid TTS settings provided'));
    }
    return await repository.updateSettings(settings);
  }
}

class GetTtsSettings implements UseCase<TtsSettings, NoParams> {
  final TtsRepository repository;

  GetTtsSettings(this.repository);

  @override
  Future<Either<Failure, TtsSettings>> call(NoParams params) async {
    return await repository.getSettings();
  }
}

class SetSpeechRate implements UseCase<void, double> {
  final TtsRepository repository;

  SetSpeechRate(this.repository);

  @override
  Future<Either<Failure, void>> call(double rate) async {
    if (rate < 0.5 || rate > 3.0) {
      return Left(InvalidSettingsFailure('Speech rate must be between 0.5 and 3.0'));
    }
    return await repository.setSpeechRate(rate);
  }
}

class SetPitch implements UseCase<void, double> {
  final TtsRepository repository;

  SetPitch(this.repository);

  @override
  Future<Either<Failure, void>> call(double pitch) async {
    if (pitch < 0.5 || pitch > 2.0) {
      return Left(InvalidSettingsFailure('Pitch must be between 0.5 and 2.0'));
    }
    return await repository.setPitch(pitch);
  }
}

class SetVolume implements UseCase<void, double> {
  final TtsRepository repository;

  SetVolume(this.repository);

  @override
  Future<Either<Failure, void>> call(double volume) async {
    if (volume < 0.0 || volume > 1.0) {
      return Left(InvalidSettingsFailure('Volume must be between 0.0 and 1.0'));
    }
    return await repository.setVolume(volume);
  }
}

class InvalidSettingsFailure extends Failure {
  InvalidSettingsFailure(String message) : super(message);
  
  @override
  List<Object?> get props => [message];
}

