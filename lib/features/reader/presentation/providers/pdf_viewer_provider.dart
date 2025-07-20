import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import '../../domain/entities/pdf_page.dart';
import '../../domain/entities/reading_position.dart';
import '../../domain/usecases/load_pdf_document.dart';
import '../../domain/usecases/navigate_pages.dart';
import '../../domain/usecases/manage_reading_position.dart';
import '../../data/datasources/pdf_reader_datasource.dart';
import '../../data/repositories/pdf_reader_repository_impl.dart';

// Data source provider
final pdfReaderDataSourceProvider = Provider<PdfReaderDataSourceImpl>((ref) {
  return PdfReaderDataSourceImpl();
});

// Repository provider
final pdfReaderRepositoryProvider = Provider<PdfReaderRepositoryImpl>((ref) {
  final dataSource = ref.watch(pdfReaderDataSourceProvider);
  return PdfReaderRepositoryImpl(dataSource: dataSource);
});

// Use case providers
final loadPdfDocumentProvider = Provider<LoadPdfDocument>((ref) {
  final repository = ref.watch(pdfReaderRepositoryProvider);
  return LoadPdfDocument(repository);
});

final navigateToPageProvider = Provider<NavigateToPage>((ref) {
  final repository = ref.watch(pdfReaderRepositoryProvider);
  return NavigateToPage(repository);
});

final getPageCountProvider = Provider<GetPageCount>((ref) {
  final repository = ref.watch(pdfReaderRepositoryProvider);
  return GetPageCount(repository);
});

final saveReadingPositionProvider = Provider<SaveReadingPosition>((ref) {
  final repository = ref.watch(pdfReaderRepositoryProvider);
  return SaveReadingPosition(repository);
});

final getReadingPositionProvider = Provider<GetReadingPosition>((ref) {
  final repository = ref.watch(pdfReaderRepositoryProvider);
  return GetReadingPosition(repository);
});

// PDF Viewer State
class PdfViewerState {
  final String? documentId;
  final String? filePath;
  final bool isLoading;
  final bool isLoaded;
  final String? error;
  final int currentPage;
  final int totalPages;
  final double zoomLevel;
  final ReadingPosition? readingPosition;
  final PdfDocument? document;
  final double loadingProgress;

  const PdfViewerState({
    this.documentId,
    this.filePath,
    this.isLoading = false,
    this.isLoaded = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 0,
    this.zoomLevel = 1.0,
    this.readingPosition,
    this.document,
    this.loadingProgress = 0.0,
  });

  PdfViewerState copyWith({
    String? documentId,
    String? filePath,
    bool? isLoading,
    bool? isLoaded,
    String? error,
    int? currentPage,
    int? totalPages,
    double? zoomLevel,
    ReadingPosition? readingPosition,
    PdfDocument? document,
    double? loadingProgress,
  }) {
    return PdfViewerState(
      documentId: documentId ?? this.documentId,
      filePath: filePath ?? this.filePath,
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      readingPosition: readingPosition ?? this.readingPosition,
      document: document ?? this.document,
      loadingProgress: loadingProgress ?? this.loadingProgress,
    );
  }

  bool get canGoToPreviousPage => currentPage > 1;
  bool get canGoToNextPage => currentPage < totalPages;
  double get progress => totalPages > 0 ? currentPage / totalPages : 0.0;
}

// PDF Viewer Notifier
class PdfViewerNotifier extends StateNotifier<PdfViewerState> {
  final LoadPdfDocument _loadPdfDocument;
  final NavigateToPage _navigateToPage;
  final GetPageCount _getPageCount;
  final SaveReadingPosition _saveReadingPosition;
  final GetReadingPosition _getReadingPosition;
  final PdfReaderDataSourceImpl _dataSource;

  PdfViewerNotifier(
    this._loadPdfDocument,
    this._navigateToPage,
    this._getPageCount,
    this._saveReadingPosition,
    this._getReadingPosition,
    this._dataSource,
  ) : super(const PdfViewerState());

  Future<void> loadDocument(String documentId, String filePath) async {
    state = state.copyWith(
      documentId: documentId,
      filePath: filePath,
      isLoading: true,
      error: null,
    );

    // Listen to loading progress
    _dataSource.getLoadingProgress(documentId).listen((progress) {
      if (mounted) {
        state = state.copyWith(loadingProgress: progress);
      }
    });

    final result = await _loadPdfDocument(
      LoadPdfDocumentParams(documentId: documentId, filePath: filePath)
    );

    result.fold(
      (failure) {
        if (mounted) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        }
      },
      (documentInfo) async {
        final totalPages = documentInfo['pageCount'] as int;
        final document = _dataSource.getDocument(documentId);
        
        // Get saved reading position
        final positionResult = await _getReadingPosition(documentId);
        ReadingPosition? savedPosition;
        positionResult.fold(
          (failure) => savedPosition = null,
          (position) => savedPosition = position,
        );

        if (mounted) {
          state = state.copyWith(
            isLoading: false,
            isLoaded: true,
            totalPages: totalPages,
            currentPage: savedPosition?.currentPage ?? 1,
            zoomLevel: savedPosition?.zoomLevel ?? 1.0,
            readingPosition: savedPosition,
            document: document,
            loadingProgress: 1.0,
          );
        }
      },
    );
  }

  Future<void> goToPage(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > state.totalPages) return;
    
    state = state.copyWith(currentPage: pageNumber);
    await _saveCurrentPosition();
  }

  Future<void> nextPage() async {
    if (state.canGoToNextPage) {
      await goToPage(state.currentPage + 1);
    }
  }

  Future<void> previousPage() async {
    if (state.canGoToPreviousPage) {
      await goToPage(state.currentPage - 1);
    }
  }

  void setZoomLevel(double zoomLevel) {
    state = state.copyWith(zoomLevel: zoomLevel);
    _saveCurrentPosition();
  }

  Future<void> _saveCurrentPosition() async {
    if (state.documentId == null) return;

    final position = ReadingPosition(
      documentId: state.documentId!,
      currentPage: state.currentPage,
      zoomLevel: state.zoomLevel,
      lastUpdated: DateTime.now(),
    );

    await _saveReadingPosition(position);
    state = state.copyWith(readingPosition: position);
  }

  Future<void> closeDocument() async {
    if (state.documentId != null) {
      await _dataSource.closeDocument(state.documentId!);
    }
    state = const PdfViewerState();
  }

  @override
  void dispose() {
    closeDocument();
    super.dispose();
  }
}

// PDF Viewer Provider
final pdfViewerProvider = StateNotifierProvider<PdfViewerNotifier, PdfViewerState>((ref) {
  final loadPdfDocument = ref.watch(loadPdfDocumentProvider);
  final navigateToPage = ref.watch(navigateToPageProvider);
  final getPageCount = ref.watch(getPageCountProvider);
  final saveReadingPosition = ref.watch(saveReadingPositionProvider);
  final getReadingPosition = ref.watch(getReadingPositionProvider);
  final dataSource = ref.watch(pdfReaderDataSourceProvider);

  return PdfViewerNotifier(
    loadPdfDocument,
    navigateToPage,
    getPageCount,
    saveReadingPosition,
    getReadingPosition,
    dataSource,
  );
});