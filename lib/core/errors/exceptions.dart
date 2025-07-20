class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}

class DocumentNotFoundException implements Exception {
  final String message;
  const DocumentNotFoundException(this.message);
}

class DocumentCorruptedException implements Exception {
  final String message;
  const DocumentCorruptedException(this.message);
}

class DocumentTooLargeException implements Exception {
  final String message;
  const DocumentTooLargeException(this.message);
}

class DocumentEncryptionException implements Exception {
  final String message;
  const DocumentEncryptionException(this.message);
}

class TtsNotAvailableException implements Exception {
  final String message;
  const TtsNotAvailableException(this.message);
}

class TtsEngineException implements Exception {
  final String message;
  const TtsEngineException(this.message);
}

class VoiceNotFoundException implements Exception {
  final String message;
  const VoiceNotFoundException(this.message);
}

class StoragePermissionException implements Exception {
  final String message;
  const StoragePermissionException(this.message);
}

class MicrophonePermissionException implements Exception {
  final String message;
  const MicrophonePermissionException(this.message);
}