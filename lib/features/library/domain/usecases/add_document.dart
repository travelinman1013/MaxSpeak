import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/document.dart';
import '../repositories/document_repository.dart';

class AddDocument implements UseCase<Document, AddDocumentParams> {
  final DocumentRepository repository;

  const AddDocument(this.repository);

  @override
  Future<Either<Failure, Document>> call(AddDocumentParams params) async {
    return await repository.addDocument(params.filePath);
  }
}

class AddDocumentParams {
  final String filePath;

  const AddDocumentParams({required this.filePath});
}