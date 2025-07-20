import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/document.dart';
import '../repositories/document_repository.dart';

class SearchDocuments implements UseCase<List<Document>, SearchDocumentsParams> {
  final DocumentRepository repository;

  const SearchDocuments(this.repository);

  @override
  Future<Either<Failure, List<Document>>> call(SearchDocumentsParams params) async {
    return await repository.searchDocuments(params.query);
  }
}

class SearchDocumentsParams {
  final String query;

  const SearchDocumentsParams({required this.query});
}