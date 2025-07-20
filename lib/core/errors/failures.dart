import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object?> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Document-specific failures
class DocumentFailure extends Failure {
  const DocumentFailure(super.message);
}

class DocumentNotFoundFailure extends Failure {
  const DocumentNotFoundFailure(super.message);
}

class DocumentCorruptedFailure extends Failure {
  const DocumentCorruptedFailure(super.message);
}

class DocumentTooLargeFailure extends Failure {
  const DocumentTooLargeFailure(super.message);
}

class DocumentEncryptionFailure extends Failure {
  const DocumentEncryptionFailure(super.message);
}

// TTS-specific failures
class TtsNotAvailableFailure extends Failure {
  const TtsNotAvailableFailure(super.message);
}

class TtsEngineFailure extends Failure {
  const TtsEngineFailure(super.message);
}

class VoiceNotFoundFailure extends Failure {
  const VoiceNotFoundFailure(super.message);
}

// Permission failures
class StoragePermissionFailure extends Failure {
  const StoragePermissionFailure(super.message);
}

class MicrophonePermissionFailure extends Failure {
  const MicrophonePermissionFailure(super.message);
}