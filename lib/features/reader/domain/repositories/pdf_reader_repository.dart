import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/pdf_page.dart';
import '../entities/reading_position.dart';

abstract class PdfReaderRepository {
  /// Load PDF document and get basic information
  Future<Either<Failure, Map<String, dynamic>>> loadDocument(String documentId, String filePath);
  
  /// Get a specific page from the PDF
  Future<Either<Failure, PdfPage>> getPage(String documentId, int pageNumber);
  
  /// Get page count for the document
  Future<Either<Failure, int>> getPageCount(String documentId);
  
  /// Save reading position for a document
  Future<Either<Failure, void>> saveReadingPosition(ReadingPosition position);
  
  /// Get saved reading position for a document
  Future<Either<Failure, ReadingPosition?>> getReadingPosition(String documentId);
  
  /// Extract text from a specific page
  Future<Either<Failure, String>> extractTextFromPage(String documentId, int pageNumber);
  
  /// Search for text in the document
  Future<Either<Failure, List<Map<String, dynamic>>>> searchText(String documentId, String query);
  
  /// Close document and free resources
  Future<Either<Failure, void>> closeDocument(String documentId);
  
  /// Get document loading progress
  Stream<double> getLoadingProgress(String documentId);
}