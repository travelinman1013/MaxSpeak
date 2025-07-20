import 'package:get_it/get_it.dart';
import '../../features/library/data/datasources/local_document_datasource.dart';
import '../../features/library/data/repositories/document_repository_impl.dart';
import '../../features/library/domain/repositories/document_repository.dart';
import '../../features/library/domain/usecases/get_all_documents.dart';
import '../../features/library/domain/usecases/add_document.dart';
import '../../features/library/domain/usecases/delete_document.dart';
import '../../features/library/domain/usecases/search_documents.dart';
import '../../features/reader/data/datasources/pdf_reader_datasource.dart';
import '../../features/reader/data/repositories/pdf_reader_repository_impl.dart';
import '../../features/reader/domain/repositories/pdf_reader_repository.dart';
import '../../features/reader/domain/usecases/load_pdf_document.dart';
import '../../features/reader/domain/usecases/navigate_pages.dart';
import '../../features/reader/domain/usecases/manage_reading_position.dart';
import '../../features/tts/data/datasources/tts_datasource.dart';
import '../../features/tts/data/repositories/tts_repository_impl.dart';
import '../../features/tts/domain/repositories/tts_repository.dart';
import '../../features/tts/domain/usecases/manage_tts_playback.dart';
import '../../features/tts/domain/usecases/manage_tts_settings.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Data sources - Library
  getIt.registerLazySingleton<LocalDocumentDataSource>(
    () => LocalDocumentDataSourceImpl(),
  );
  
  // Data sources - Reader
  getIt.registerLazySingleton<PdfReaderDataSource>(
    () => PdfReaderDataSourceImpl(),
  );
  
  // Data sources - TTS
  getIt.registerLazySingleton<TtsDataSource>(
    () => TtsDataSourceImpl(),
  );
  
  // Repositories - Library
  getIt.registerLazySingleton<DocumentRepository>(
    () => DocumentRepositoryImpl(
      localDataSource: getIt(),
    ),
  );
  
  // Repositories - Reader
  getIt.registerLazySingleton<PdfReaderRepository>(
    () => PdfReaderRepositoryImpl(
      dataSource: getIt(),
    ),
  );
  
  // Repositories - TTS
  getIt.registerLazySingleton<TtsRepository>(
    () => TtsRepositoryImpl(
      dataSource: getIt(),
    ),
  );
  
  // Use cases - Library
  getIt.registerLazySingleton(() => GetAllDocuments(getIt()));
  getIt.registerLazySingleton(() => AddDocument(getIt()));
  getIt.registerLazySingleton(() => DeleteDocument(getIt()));
  getIt.registerLazySingleton(() => SearchDocuments(getIt()));
  
  // Use cases - Reader
  getIt.registerLazySingleton(() => LoadPdfDocument(getIt()));
  getIt.registerLazySingleton(() => NavigateToPage(getIt()));
  getIt.registerLazySingleton(() => GetPageCount(getIt()));
  getIt.registerLazySingleton(() => SaveReadingPosition(getIt()));
  getIt.registerLazySingleton(() => GetReadingPosition(getIt()));
  getIt.registerLazySingleton(() => ExtractTextFromPage(getIt()));
  
  // Use cases - TTS
  getIt.registerLazySingleton(() => SpeakText(getIt()));
  getIt.registerLazySingleton(() => PauseSpeech(getIt()));
  getIt.registerLazySingleton(() => ResumeSpeech(getIt()));
  getIt.registerLazySingleton(() => StopSpeech(getIt()));
  getIt.registerLazySingleton(() => CheckIfSpeaking(getIt()));
  getIt.registerLazySingleton(() => GetAvailableVoices(getIt()));
  getIt.registerLazySingleton(() => SetTtsVoice(getIt()));
  getIt.registerLazySingleton(() => UpdateTtsSettings(getIt()));
  getIt.registerLazySingleton(() => GetTtsSettings(getIt()));
  getIt.registerLazySingleton(() => SetSpeechRate(getIt()));
  getIt.registerLazySingleton(() => SetPitch(getIt()));
  getIt.registerLazySingleton(() => SetVolume(getIt()));
}