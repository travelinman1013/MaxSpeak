import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/document.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/local_document_datasource.dart';
import '../models/document_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final LocalDocumentDataSource localDataSource;

  const DocumentRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Document>>> getAllDocuments() async {
    try {
      final documentModels = await localDataSource.getAllDocuments();
      final documents = documentModels.map((model) => model.toEntity()).toList();
      return Right(documents);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error in getAllDocuments: $e');
      }
      return Left(CacheFailure('Failed to retrieve documents'));
    }
  }

  @override
  Future<Either<Failure, Document?>> getDocumentById(String id) async {
    try {
      final documentModel = await localDataSource.getDocumentById(id);
      final document = documentModel?.toEntity();
      return Right(document);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error in getDocumentById: $e');
      }
      return Left(CacheFailure('Failed to retrieve document'));
    }
  }

  @override
  Future<Either<Failure, Document>> addDocument(String filePath) async {
    try {
      final documentModel = await localDataSource.addDocument(filePath);
      final document = documentModel.toEntity();
      
      if (kDebugMode) {
        print('Document added successfully: ${document.title}');
      }
      
      return Right(document);
    } on DocumentNotFoundException catch (e) {
      return Left(DocumentNotFoundFailure(e.message));
    } on DocumentTooLargeException catch (e) {
      return Left(DocumentTooLargeFailure(e.message));
    } on DocumentCorruptedException catch (e) {
      return Left(DocumentCorruptedFailure(e.message));
    } on DocumentEncryptionException catch (e) {
      return Left(DocumentEncryptionFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error in addDocument: $e');
      }
      return Left(DocumentFailure('Failed to add document'));
    }
  }

  @override
  Future<Either<Failure, Document>> updateDocument(Document document) async {
    try {
      final documentModel = DocumentModel.fromEntity(document);
      final updatedModel = await localDataSource.updateDocument(documentModel);
      final updatedDocument = updatedModel.toEntity();
      
      if (kDebugMode) {
        print('Document updated successfully: ${document.title}');
      }
      
      return Right(updatedDocument);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error in updateDocument: $e');
      }
      return Left(DocumentFailure('Failed to update document'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument(String id) async {
    try {
      await localDataSource.deleteDocument(id);
      
      if (kDebugMode) {
        print('Document deleted successfully: $id');
      }
      
      return const Right(null);
    } on DocumentNotFoundException catch (e) {
      return Left(DocumentFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error in deleteDocument: $e');
      }
      return Left(DocumentFailure('Failed to delete document'));
    }
  }

  @override
  Future<Either<Failure, void>> updateReadingProgress(
    String id,
    double progress,
    int currentPage,
  ) async {
    try {
      await localDataSource.updateReadingProgress(id, progress, currentPage);
      
      if (kDebugMode) {
        print('Reading progress updated: $id - ${(progress * 100).round()}%');
      }
      
      return const Right(null);
    } on DocumentNotFoundException catch (e) {
      return Left(DocumentFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error in updateReadingProgress: $e');
      }
      return Left(DocumentFailure('Failed to update reading progress'));
    }
  }

  @override
  Future<Either<Failure, List<Document>>> searchDocuments(String query) async {
    try {
      final documentModels = await localDataSource.searchDocuments(query);
      final documents = documentModels.map((model) => model.toEntity()).toList();
      
      if (kDebugMode && query.isNotEmpty) {
        print('Search completed: "${query}" - ${documents.length} results');
      }
      
      return Right(documents);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error in searchDocuments: $e');
      }
      return Left(CacheFailure('Failed to search documents'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalDocuments() async {
    try {
      final documentModels = await localDataSource.getAllDocuments();
      return Right(documentModels.length);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error in getTotalDocuments: $e');
      }
      return Left(CacheFailure('Failed to get document count'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalLibrarySize() async {
    try {
      final documentModels = await localDataSource.getAllDocuments();
      final totalSizeBytes = documentModels.fold<int>(
        0,
        (sum, document) => sum + document.fileSizeBytes,
      );
      
      // Convert to MB
      final totalSizeMB = totalSizeBytes / (1024 * 1024);
      return Right(totalSizeMB);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error in getTotalLibrarySize: $e');
      }
      return Left(CacheFailure('Failed to calculate library size'));
    }
  }
}