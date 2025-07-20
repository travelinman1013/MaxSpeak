import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/document.dart';
import '../repositories/document_repository.dart';

class GetAllDocuments implements UseCase<List<Document>, NoParams> {
  final DocumentRepository repository;

  const GetAllDocuments(this.repository);

  @override
  Future<Either<Failure, List<Document>>> call(NoParams params) async {
    return await repository.getAllDocuments();
  }
}