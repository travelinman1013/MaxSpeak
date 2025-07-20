import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reading_position.dart';
import '../repositories/pdf_reader_repository.dart';

class SaveReadingPosition implements UseCase<void, ReadingPosition> {
  final PdfReaderRepository repository;

  SaveReadingPosition(this.repository);

  @override
  Future<Either<Failure, void>> call(ReadingPosition position) async {
    return await repository.saveReadingPosition(position);
  }
}

class GetReadingPosition implements UseCase<ReadingPosition?, String> {
  final PdfReaderRepository repository;

  GetReadingPosition(this.repository);

  @override
  Future<Either<Failure, ReadingPosition?>> call(String documentId) async {
    return await repository.getReadingPosition(documentId);
  }
}

class ExtractTextFromPage implements UseCase<String, ExtractTextParams> {
  final PdfReaderRepository repository;

  ExtractTextFromPage(this.repository);

  @override
  Future<Either<Failure, String>> call(ExtractTextParams params) async {
    return await repository.extractTextFromPage(params.documentId, params.pageNumber);
  }
}

class ExtractTextParams {
  final String documentId;
  final int pageNumber;

  ExtractTextParams({
    required this.documentId,
    required this.pageNumber,
  });
}