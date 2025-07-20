import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/pdf_page.dart';
import '../../domain/entities/reading_position.dart';
import '../../domain/repositories/pdf_reader_repository.dart';
import '../datasources/pdf_reader_datasource.dart';
import '../models/reading_position_model.dart';

class PdfReaderRepositoryImpl implements PdfReaderRepository {
  final PdfReaderDataSource dataSource;

  PdfReaderRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> loadDocument(String documentId, String filePath) async {
    try {
      final result = await dataSource.loadDocument(documentId, filePath);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error loading document: $e'));
    }
  }

  @override
  Future<Either<Failure, PdfPage>> getPage(String documentId, int pageNumber) async {
    try {
      final result = await dataSource.getPage(documentId, pageNumber);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error getting page: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getPageCount(String documentId) async {
    try {
      final result = await dataSource.getPageCount(documentId);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error getting page count: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveReadingPosition(ReadingPosition position) async {
    try {
      final positionModel = ReadingPositionModel.fromEntity(position);
      await dataSource.saveReadingPosition(positionModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error saving reading position: $e'));
    }
  }

  @override
  Future<Either<Failure, ReadingPosition?>> getReadingPosition(String documentId) async {
    try {
      final result = await dataSource.getReadingPosition(documentId);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error getting reading position: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> extractTextFromPage(String documentId, int pageNumber) async {
    try {
      final result = await dataSource.extractTextFromPage(documentId, pageNumber);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error extracting text: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> searchText(String documentId, String query) async {
    try {
      final result = await dataSource.searchText(documentId, query);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error searching text: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> closeDocument(String documentId) async {
    try {
      await dataSource.closeDocument(documentId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error closing document: $e'));
    }
  }

  @override
  Stream<double> getLoadingProgress(String documentId) {
    return dataSource.getLoadingProgress(documentId);
  }
}