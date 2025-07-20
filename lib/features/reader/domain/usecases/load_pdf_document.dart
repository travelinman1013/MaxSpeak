import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/pdf_reader_repository.dart';

class LoadPdfDocument implements UseCase<Map<String, dynamic>, LoadPdfDocumentParams> {
  final PdfReaderRepository repository;

  LoadPdfDocument(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(LoadPdfDocumentParams params) async {
    return await repository.loadDocument(params.documentId, params.filePath);
  }
}

class LoadPdfDocumentParams {
  final String documentId;
  final String filePath;

  LoadPdfDocumentParams({
    required this.documentId, 
    required this.filePath,
  });
}