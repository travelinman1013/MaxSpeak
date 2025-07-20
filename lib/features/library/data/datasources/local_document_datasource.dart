import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/document_model.dart';

abstract class LocalDocumentDataSource {
  Future<List<DocumentModel>> getAllDocuments();
  Future<DocumentModel?> getDocumentById(String id);
  Future<DocumentModel> addDocument(String filePath);
  Future<DocumentModel> updateDocument(DocumentModel document);
  Future<void> deleteDocument(String id);
  Future<void> updateReadingProgress(String id, double progress, int currentPage);
  Future<List<DocumentModel>> searchDocuments(String query);
}

class LocalDocumentDataSourceImpl implements LocalDocumentDataSource {
  static const String _boxName = AppConstants.documentsBox;
  final _uuid = const Uuid();

  Box<DocumentModel>? _box;

  Future<Box<DocumentModel>> get box async {
    _box ??= await Hive.openBox<DocumentModel>(_boxName);
    return _box!;
  }

  @override
  Future<List<DocumentModel>> getAllDocuments() async {
    try {
      final documentsBox = await box;
      return documentsBox.values.toList();
    } catch (e) {
      throw CacheException('Failed to get documents: ${e.toString()}');
    }
  }

  @override
  Future<DocumentModel?> getDocumentById(String id) async {
    try {
      final documentsBox = await box;
      return documentsBox.get(id);
    } catch (e) {
      throw CacheException('Failed to get document: ${e.toString()}');
    }
  }

  @override
  Future<DocumentModel> addDocument(String filePath) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        throw DocumentNotFoundException('File not found: $filePath');
      }

      final fileStats = await file.stat();
      
      // Check file size
      if (fileStats.size > AppConstants.maxPdfSizeBytes) {
        throw DocumentTooLargeException(AppConstants.pdfTooLargeError);
      }

      // Extract filename without extension for title
      final fileName = file.path.split('/').last;
      final title = fileName.substring(0, fileName.lastIndexOf('.'));

      final document = DocumentModel(
        id: _uuid.v4(),
        title: title,
        filePath: filePath,
        originalFileName: fileName,
        totalPages: 0, // Will be updated when PDF is parsed
        fileSizeBytes: fileStats.size,
        dateAdded: DateTime.now(),
        lastOpened: DateTime.now(),
        readingProgress: 0.0,
        currentPage: 1,
        isEncrypted: true,
      );

      final documentsBox = await box;
      await documentsBox.put(document.id, document);
      
      return document;
    } catch (e) {
      if (e is DocumentNotFoundException || e is DocumentTooLargeException) {
        rethrow;
      }
      throw CacheException('Failed to add document: ${e.toString()}');
    }
  }

  @override
  Future<DocumentModel> updateDocument(DocumentModel document) async {
    try {
      final documentsBox = await box;
      await documentsBox.put(document.id, document);
      return document;
    } catch (e) {
      throw CacheException('Failed to update document: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteDocument(String id) async {
    try {
      final documentsBox = await box;
      final document = documentsBox.get(id);
      
      if (document == null) {
        throw DocumentNotFoundException('Document not found: $id');
      }

      // Delete the file if it exists
      final file = File(document.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Delete cover image if it exists
      if (document.coverImagePath != null) {
        final coverFile = File(document.coverImagePath!);
        if (await coverFile.exists()) {
          await coverFile.delete();
        }
      }

      await documentsBox.delete(id);
    } catch (e) {
      if (e is DocumentNotFoundException) {
        rethrow;
      }
      throw CacheException('Failed to delete document: ${e.toString()}');
    }
  }

  @override
  Future<void> updateReadingProgress(String id, double progress, int currentPage) async {
    try {
      final documentsBox = await box;
      final document = documentsBox.get(id);
      
      if (document == null) {
        throw DocumentNotFoundException('Document not found: $id');
      }

      document.readingProgress = progress.clamp(0.0, 1.0);
      document.currentPage = currentPage;
      document.lastOpened = DateTime.now();
      
      await documentsBox.put(id, document);
    } catch (e) {
      if (e is DocumentNotFoundException) {
        rethrow;
      }
      throw CacheException('Failed to update reading progress: ${e.toString()}');
    }
  }

  @override
  Future<List<DocumentModel>> searchDocuments(String query) async {
    try {
      final documentsBox = await box;
      final allDocuments = documentsBox.values.toList();
      
      if (query.trim().isEmpty) {
        return allDocuments;
      }

      final searchQuery = query.toLowerCase();
      return allDocuments.where((document) {
        return document.title.toLowerCase().contains(searchQuery) ||
               document.originalFileName.toLowerCase().contains(searchQuery);
      }).toList();
    } catch (e) {
      throw CacheException('Failed to search documents: ${e.toString()}');
    }
  }
}