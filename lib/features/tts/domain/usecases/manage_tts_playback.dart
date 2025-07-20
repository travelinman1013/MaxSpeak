import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/tts_repository.dart';

class SpeakText implements UseCase<void, String> {
  final TtsRepository repository;

  SpeakText(this.repository);

  @override
  Future<Either<Failure, void>> call(String text) async {
    if (text.trim().isEmpty) {
      return Left(InvalidInputFailure('Text cannot be empty'));
    }
    return await repository.speak(text);
  }
}

class PauseSpeech implements UseCase<void, NoParams> {
  final TtsRepository repository;

  PauseSpeech(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.pause();
  }
}

class ResumeSpeech implements UseCase<void, NoParams> {
  final TtsRepository repository;

  ResumeSpeech(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.resume();
  }
}

class StopSpeech implements UseCase<void, NoParams> {
  final TtsRepository repository;

  StopSpeech(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.stop();
  }
}

class CheckIfSpeaking implements UseCase<bool, NoParams> {
  final TtsRepository repository;

  CheckIfSpeaking(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.isSpeaking();
  }
}

class InvalidInputFailure extends Failure {
  InvalidInputFailure(String message) : super(message);
  
  @override
  List<Object?> get props => [message];
}