import 'package:get_it/get_it.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive/hive.dart';
import '../../features/library/data/datasources/local_document_datasource.dart';
import '../../features/library/data/repositories/document_repository_impl.dart';
import '../../features/library/domain/repositories/document_repository.dart';
import '../../features/library/domain/usecases/get_all_documents.dart';
import '../../features/library/domain/usecases/add_document.dart';
import '../../features/library/domain/usecases/delete_document.dart';
import '../../features/library/domain/usecases/update_reading_progress.dart';
import '../../features/tts/data/datasources/tts_datasource.dart';
import '../../features/tts/data/repositories/tts_repository_impl.dart';
import '../../features/tts/domain/repositories/tts_repository.dart';
import '../../features/tts/domain/usecases/speak_text.dart';
import '../../features/tts/domain/usecases/pause_speaking.dart';
import '../../features/tts/domain/usecases/stop_speaking.dart';
import '../../features/tts/domain/usecases/set_speech_rate.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // External dependencies
  getIt.registerLazySingleton(() => FlutterTts());
  
  // Data sources
  getIt.registerLazySingleton<LocalDocumentDataSource>(
    () => LocalDocumentDataSourceImpl(),
  );
  
  getIt.registerLazySingleton<TtsDataSource>(
    () => TtsDataSourceImpl(getIt()),
  );
  
  // Repositories
  getIt.registerLazySingleton<DocumentRepository>(
    () => DocumentRepositoryImpl(getIt()),
  );
  
  getIt.registerLazySingleton<TtsRepository>(
    () => TtsRepositoryImpl(getIt()),
  );
  
  // Use cases - Library
  getIt.registerLazySingleton(() => GetAllDocuments(getIt()));
  getIt.registerLazySingleton(() => AddDocument(getIt()));
  getIt.registerLazySingleton(() => DeleteDocument(getIt()));
  getIt.registerLazySingleton(() => UpdateReadingProgress(getIt()));
  
  // Use cases - TTS
  getIt.registerLazySingleton(() => SpeakText(getIt()));
  getIt.registerLazySingleton(() => PauseSpeaking(getIt()));
  getIt.registerLazySingleton(() => StopSpeaking(getIt()));
  getIt.registerLazySingleton(() => SetSpeechRate(getIt()));
}