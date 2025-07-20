import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/document.dart';

abstract class DocumentRepository {
  Future<Either<Failure, List<Document>>> getAllDocuments();
  Future<Either<Failure, Document?>> getDocumentById(String id);
  Future<Either<Failure, Document>> addDocument(String filePath);
  Future<Either<Failure, Document>> updateDocument(Document document);
  Future<Either<Failure, void>> deleteDocument(String id);
  Future<Either<Failure, void>> updateReadingProgress(String id, double progress, int currentPage);
  Future<Either<Failure, List<Document>>> searchDocuments(String query);
  Future<Either<Failure, int>> getTotalDocuments();
  Future<Either<Failure, double>> getTotalLibrarySize();
}