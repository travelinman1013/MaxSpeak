import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/pdf_page.dart';
import '../repositories/pdf_reader_repository.dart';

class NavigateToPage implements UseCase<PdfPage, NavigateToPageParams> {
  final PdfReaderRepository repository;

  NavigateToPage(this.repository);

  @override
  Future<Either<Failure, PdfPage>> call(NavigateToPageParams params) async {
    return await repository.getPage(params.documentId, params.pageNumber);
  }
}

class NavigateToPageParams {
  final String documentId;
  final int pageNumber;

  NavigateToPageParams({
    required this.documentId,
    required this.pageNumber,
  });
}

class GetPageCount implements UseCase<int, String> {
  final PdfReaderRepository repository;

  GetPageCount(this.repository);

  @override
  Future<Either<Failure, int>> call(String documentId) async {
    return await repository.getPageCount(documentId);
  }
}