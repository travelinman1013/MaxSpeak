import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/services/encryption_service.dart';
import '../models/document_model.dart';

abstract class LocalDocumentDataSource {
  Future<List<DocumentModel>> getAllDocuments();
  Future<DocumentModel?> getDocumentById(String id);
  Future<DocumentModel> addDocument(String filePath);
  Future<DocumentModel> updateDocument(DocumentModel document);
  Future<void> deleteDocument(String id);
  Future<void> updateReadingProgress(String id, double progress, int currentPage);
  Future<List<DocumentModel>> searchDocuments(String query);
  Future<String> getReadableFilePath(String documentId);
}

class LocalDocumentDataSourceImpl implements LocalDocumentDataSource {
  final DatabaseService _databaseService;
  final PdfService _pdfService;
  final EncryptionService _encryptionService;
  final _uuid = const Uuid();

  LocalDocumentDataSourceImpl({
    DatabaseService? databaseService,
    PdfService? pdfService,
    EncryptionService? encryptionService,
  }) : _databaseService = databaseService ?? DatabaseService.instance,
       _pdfService = pdfService ?? PdfService.instance,
       _encryptionService = encryptionService ?? EncryptionService.instance;

  Box<DocumentModel> get _documentsBox => _databaseService.documentsBox;

  @override
  Future<List<DocumentModel>> getAllDocuments() async {
    try {
      final documents = _documentsBox.values.toList();
      // Sort by last opened (most recent first)
      documents.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
      return documents;
    } catch (e) {
      throw CacheException('Failed to get documents: ${e.toString()}');
    }
  }

  @override
  Future<DocumentModel?> getDocumentById(String id) async {
    try {
      return _documentsBox.get(id);
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

      // Validate PDF file format
      if (!await _pdfService.isValidPdf(filePath)) {
        throw DocumentCorruptedException('The selected file is not a valid PDF document');
      }

      // Extract filename without extension for title
      final fileName = file.path.split('/').last;
      final title = fileName.substring(0, fileName.lastIndexOf('.'));

      // Get PDF page count before encryption
      int totalPages = 0;
      try {
        totalPages = await _pdfService.getPageCount(filePath);
      } catch (e) {
        // If page count fails, document can still be added
        // Page count will be 0 and can be updated later
        if (kDebugMode) {
          print('Failed to get page count for $fileName: $e');
        }
      }

      // Generate document ID first
      final documentId = _uuid.v4();

      // Generate thumbnail before encryption
      String? coverImagePath;
      try {
        coverImagePath = await _pdfService.generateThumbnail(filePath, documentId);
        if (kDebugMode && coverImagePath != null) {
          print('Thumbnail generated successfully for $fileName');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Warning: Failed to generate thumbnail for $fileName: $e');
        }
        // Continue without thumbnail if it fails
      }

      // Encrypt the PDF file
      String encryptedFilePath = filePath;
      bool isEncrypted = false;
      
      try {
        // Initialize encryption service if not already done
        if (!_encryptionService.isInitialized) {
          await _encryptionService.initialize();
        }
        
        // Generate secure storage path
        final secureStoragePath = await _encryptionService.getSecureStoragePath(fileName);
        
        // Encrypt the file
        encryptedFilePath = await _encryptionService.encryptFile(filePath, secureStoragePath);
        isEncrypted = true;
        
        if (kDebugMode) {
          print('PDF encrypted successfully: $fileName');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Warning: Failed to encrypt PDF $fileName: $e');
          print('Document will be stored unencrypted');
        }
        // Continue without encryption if it fails
        // In production, you might want to fail here for security
      }

      final document = DocumentModel(
        id: documentId,
        title: title,
        filePath: encryptedFilePath,
        originalFileName: fileName,
        totalPages: totalPages,
        fileSizeBytes: fileStats.size,
        dateAdded: DateTime.now(),
        lastOpened: DateTime.now(),
        readingProgress: 0.0,
        currentPage: 1,
        coverImagePath: coverImagePath,
        isEncrypted: isEncrypted,
      );

      await _documentsBox.put(document.id, document);
      
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
      await _documentsBox.put(document.id, document);
      return document;
    } catch (e) {
      throw CacheException('Failed to update document: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteDocument(String id) async {
    try {
      final document = _documentsBox.get(id);
      
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

      await _documentsBox.delete(id);
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
      final document = _documentsBox.get(id);
      
      if (document == null) {
        throw DocumentNotFoundException('Document not found: $id');
      }

      document.readingProgress = progress.clamp(0.0, 1.0);
      document.currentPage = currentPage;
      document.lastOpened = DateTime.now();
      
      await _documentsBox.put(id, document);
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
      final allDocuments = _documentsBox.values.toList();
      
      if (query.trim().isEmpty) {
        allDocuments.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
        return allDocuments;
      }

      final searchQuery = query.toLowerCase();
      final filteredDocuments = allDocuments.where((document) {
        return document.title.toLowerCase().contains(searchQuery) ||
               document.originalFileName.toLowerCase().contains(searchQuery);
      }).toList();
      
      // Sort by relevance: exact title matches first, then partial matches
      filteredDocuments.sort((a, b) {
        final aTitle = a.title.toLowerCase();
        final bTitle = b.title.toLowerCase();
        
        if (aTitle == searchQuery && bTitle != searchQuery) return -1;
        if (bTitle == searchQuery && aTitle != searchQuery) return 1;
        if (aTitle.startsWith(searchQuery) && !bTitle.startsWith(searchQuery)) return -1;
        if (bTitle.startsWith(searchQuery) && !aTitle.startsWith(searchQuery)) return 1;
        
        return b.lastOpened.compareTo(a.lastOpened);
      });
      
      return filteredDocuments;
    } catch (e) {
      throw CacheException('Failed to search documents: ${e.toString()}');
    }
  }

  @override
  Future<String> getReadableFilePath(String documentId) async {
    try {
      final document = _documentsBox.get(documentId);
      
      if (document == null) {
        throw DocumentNotFoundException('Document not found: $documentId');
      }

      // If document is not encrypted, return the original path
      if (!document.isEncrypted) {
        return document.filePath;
      }

      // If encrypted, we need to decrypt it to a temporary location
      // Initialize encryption service if not already done
      if (!_encryptionService.isInitialized) {
        await _encryptionService.initialize();
      }

      // Create temporary file path for decrypted content
      final tempDir = Directory.systemTemp;
      final originalExtension = _encryptionService.getOriginalExtension(document.filePath) ?? 'pdf';
      final tempFilePath = '${tempDir.path}/temp_${document.id}.$originalExtension';

      // Decrypt the file to temporary location
      await _encryptionService.decryptFile(document.filePath, tempFilePath);
      
      if (kDebugMode) {
        print('Document decrypted for reading: ${document.title}');
      }
      
      return tempFilePath;
    } catch (e) {
      if (e is DocumentNotFoundException) {
        rethrow;
      }
      throw CacheException('Failed to get readable file path: ${e.toString()}');
    }
  }
}