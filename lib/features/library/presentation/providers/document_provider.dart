import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/service_locator.dart';
import '../../domain/entities/document.dart';
import '../../domain/usecases/add_document.dart';
import '../../domain/usecases/delete_document.dart';
import '../../domain/usecases/get_all_documents.dart';
import '../../domain/usecases/search_documents.dart';
import '../../../../core/usecases/usecase.dart';

// Use case providers using GetIt service locator
final getAllDocumentsProvider = Provider<GetAllDocuments>((ref) {
  return getIt<GetAllDocuments>();
});

final addDocumentProvider = Provider<AddDocument>((ref) {
  return getIt<AddDocument>();
});

final deleteDocumentProvider = Provider<DeleteDocument>((ref) {
  return getIt<DeleteDocument>();
});

final searchDocumentsProvider = Provider<SearchDocuments>((ref) {
  return getIt<SearchDocuments>();
});

// Document state provider
final documentsProvider = StateNotifierProvider<DocumentsNotifier, DocumentsState>((ref) {
  final getAllDocuments = ref.watch(getAllDocumentsProvider);
  final addDocument = ref.watch(addDocumentProvider);
  final deleteDocument = ref.watch(deleteDocumentProvider);
  final searchDocuments = ref.watch(searchDocumentsProvider);
  
  return DocumentsNotifier(
    getAllDocuments: getAllDocuments,
    addDocument: addDocument,
    deleteDocument: deleteDocument,
    searchDocuments: searchDocuments,
  );
});

// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered documents provider that combines documents and search
final filteredDocumentsProvider = Provider<List<Document>>((ref) {
  final documentsState = ref.watch(documentsProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  
  if (documentsState.isLoading) return [];
  
  final documents = documentsState.documents;
  
  if (searchQuery.isEmpty) {
    return documents;
  }
  
  final query = searchQuery.toLowerCase();
  return documents.where((doc) {
    return doc.title.toLowerCase().contains(query) ||
           doc.originalFileName.toLowerCase().contains(query);
  }).toList();
});

// Document state classes
class DocumentsState {
  final List<Document> documents;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  const DocumentsState({
    this.documents = const [],
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
  });

  DocumentsState copyWith({
    List<Document>? documents,
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) {
    return DocumentsState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  bool get hasDocuments => documents.isNotEmpty;
  bool get isEmpty => documents.isEmpty && !isLoading;
  bool get hasError => error != null;
}

// Documents notifier
class DocumentsNotifier extends StateNotifier<DocumentsState> {
  final GetAllDocuments getAllDocuments;
  final AddDocument addDocument;
  final DeleteDocument deleteDocument;
  final SearchDocuments searchDocuments;

  DocumentsNotifier({
    required this.getAllDocuments,
    required this.addDocument,
    required this.deleteDocument,
    required this.searchDocuments,
  }) : super(const DocumentsState());

  Future<void> initialize() async {
    if (state.isInitialized) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      // Initialize database first
      await DatabaseService.instance.initialize();
      
      // Verify database is ready
      final stats = DatabaseService.instance.getStats();
      if (stats['isInitialized'] != true) {
        throw Exception('Database initialization verification failed');
      }
      
      // Load documents
      await loadDocuments();
      
      state = state.copyWith(isInitialized: true);
      
      if (kDebugMode) {
        print('DocumentsNotifier initialized with ${state.documents.length} documents');
        print('Database stats: $stats');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize: ${e.toString()}',
      );
      
      if (kDebugMode) {
        print('Error initializing DocumentsNotifier: $e');
      }
    }
  }

  Future<void> loadDocuments() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await getAllDocuments(const NoParams());
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        
        if (kDebugMode) {
          print('Error loading documents: ${failure.message}');
        }
      },
      (documents) {
        state = state.copyWith(
          documents: documents,
          isLoading: false,
          error: null,
        );
        
        if (kDebugMode) {
          print('Loaded ${documents.length} documents');
        }
      },
    );
  }

  Future<bool> addDocumentFromPath(String filePath) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await addDocument(AddDocumentParams(filePath: filePath));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        
        if (kDebugMode) {
          print('Error adding document: ${failure.message}');
        }
        
        return false;
      },
      (document) {
        final updatedDocuments = [...state.documents, document];
        // Sort by last opened (most recent first)
        updatedDocuments.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
        
        state = state.copyWith(
          documents: updatedDocuments,
          isLoading: false,
          error: null,
        );
        
        if (kDebugMode) {
          print('Document added successfully: ${document.title}');
        }
        
        return true;
      },
    );
  }

  Future<bool> removeDocument(String documentId) async {
    final result = await deleteDocument(DeleteDocumentParams(documentId: documentId));
    
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        
        if (kDebugMode) {
          print('Error deleting document: ${failure.message}');
        }
        
        return false;
      },
      (_) {
        final updatedDocuments = state.documents
            .where((doc) => doc.id != documentId)
            .toList();
        
        state = state.copyWith(
          documents: updatedDocuments,
          error: null,
        );
        
        if (kDebugMode) {
          print('Document deleted successfully: $documentId');
        }
        
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Get document by ID
  Document? getDocumentById(String id) {
    try {
      return state.documents.firstWhere((doc) => doc.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get library statistics
  Map<String, dynamic> getLibraryStats() {
    final totalDocuments = state.documents.length;
    final totalSizeBytes = state.documents.fold<int>(
      0,
      (sum, doc) => sum + doc.fileSizeBytes,
    );
    final totalSizeMB = totalSizeBytes / (1024 * 1024);
    
    final readDocuments = state.documents.where((doc) => doc.isCompleted).length;
    final inProgressDocuments = state.documents.where((doc) => doc.isStarted && !doc.isCompleted).length;
    
    return {
      'totalDocuments': totalDocuments,
      'totalSizeMB': totalSizeMB,
      'readDocuments': readDocuments,
      'inProgressDocuments': inProgressDocuments,
      'unreadDocuments': totalDocuments - readDocuments - inProgressDocuments,
    };
  }
}