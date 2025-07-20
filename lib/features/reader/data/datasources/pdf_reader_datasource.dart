import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/pdf_page_model.dart';
import '../models/reading_position_model.dart';

abstract class PdfReaderDataSource {
  Future<Map<String, dynamic>> loadDocument(String documentId, String filePath);
  Future<PdfPageModel> getPage(String documentId, int pageNumber);
  Future<int> getPageCount(String documentId);
  Future<void> saveReadingPosition(ReadingPositionModel position);
  Future<ReadingPositionModel?> getReadingPosition(String documentId);
  Future<String> extractTextFromPage(String documentId, int pageNumber);
  Future<List<Map<String, dynamic>>> searchText(String documentId, String query);
  Future<void> closeDocument(String documentId);
  Stream<double> getLoadingProgress(String documentId);
}

class PdfReaderDataSourceImpl implements PdfReaderDataSource {
  final Map<String, PdfDocument> _openDocuments = {};
  final Map<String, StreamController<double>> _progressControllers = {};
  final Map<String, Map<String, dynamic>> _documentInfo = {};

  @override
  Future<Map<String, dynamic>> loadDocument(String documentId, String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw CacheException('PDF file not found: $filePath');
      }

      // Close existing document if already open
      await closeDocument(documentId);

      // Create progress controller
      _progressControllers[documentId] = StreamController<double>.broadcast();
      _progressControllers[documentId]!.add(0.0);

      // Open the PDF document
      final document = await PdfDocument.openFile(filePath);
      _openDocuments[documentId] = document;

      // Get document information
      final info = {
        'documentId': documentId,
        'filePath': filePath,
        'pageCount': document.pagesCount,
        'isLoaded': true,
        'loadedAt': DateTime.now(),
      };

      _documentInfo[documentId] = info;
      _progressControllers[documentId]!.add(1.0);

      if (kDebugMode) {
        print('PDF document loaded: $documentId with ${document.pagesCount} pages');
      }

      return info;
    } catch (e) {
      _progressControllers[documentId]?.add(0.0);
      if (kDebugMode) {
        print('Error loading PDF document: $e');
      }
      throw CacheException('Failed to load PDF document: $e');
    }
  }

  @override
  Future<PdfPageModel> getPage(String documentId, int pageNumber) async {
    try {
      final document = _openDocuments[documentId];
      if (document == null) {
        throw CacheException('Document not loaded: $documentId');
      }

      if (pageNumber < 1 || pageNumber > document.pagesCount) {
        throw CacheException('Invalid page number: $pageNumber');
      }

      final page = await document.getPage(pageNumber);
      
      final pageModel = PdfPageModel(
        pageNumber: pageNumber,
        width: page.width,
        height: page.height,
        isLoaded: true,
      );

      // Don't close the page here as it might be needed for rendering
      
      return pageModel;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting PDF page: $e');
      }
      throw CacheException('Failed to get PDF page: $e');
    }
  }

  @override
  Future<int> getPageCount(String documentId) async {
    try {
      final document = _openDocuments[documentId];
      if (document == null) {
        throw CacheException('Document not loaded: $documentId');
      }

      return document.pagesCount;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting page count: $e');
      }
      throw CacheException('Failed to get page count: $e');
    }
  }

  @override
  Future<void> saveReadingPosition(ReadingPositionModel position) async {
    try {
      // For now, store in memory. Later we can persist to Hive
      // This is a simplified implementation
      if (kDebugMode) {
        print('Saving reading position for ${position.documentId}: page ${position.currentPage}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving reading position: $e');
      }
      throw CacheException('Failed to save reading position: $e');
    }
  }

  @override
  Future<ReadingPositionModel?> getReadingPosition(String documentId) async {
    try {
      // For now, return a default position. Later we can retrieve from Hive
      return ReadingPositionModel(
        documentId: documentId,
        currentPage: 1,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting reading position: $e');
      }
      return null;
    }
  }

  @override
  Future<String> extractTextFromPage(String documentId, int pageNumber) async {
    try {
      final document = _openDocuments[documentId];
      if (document == null) {
        throw CacheException('Document not loaded: $documentId');
      }

      // Note: pdfx doesn't have built-in text extraction
      // This would need a different PDF library or external service
      // For now, return placeholder
      return 'Text extraction not yet implemented for page $pageNumber';
    } catch (e) {
      if (kDebugMode) {
        print('Error extracting text: $e');
      }
      throw CacheException('Failed to extract text: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchText(String documentId, String query) async {
    try {
      // Text search would require text extraction first
      // Return empty results for now
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error searching text: $e');
      }
      throw CacheException('Failed to search text: $e');
    }
  }

  @override
  Future<void> closeDocument(String documentId) async {
    try {
      final document = _openDocuments[documentId];
      if (document != null) {
        await document.close();
        _openDocuments.remove(documentId);
      }

      _progressControllers[documentId]?.close();
      _progressControllers.remove(documentId);
      _documentInfo.remove(documentId);

      if (kDebugMode) {
        print('PDF document closed: $documentId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error closing document: $e');
      }
    }
  }

  @override
  Stream<double> getLoadingProgress(String documentId) {
    final controller = _progressControllers[documentId];
    if (controller == null) {
      return Stream.value(0.0);
    }
    return controller.stream;
  }

  // Get the actual PdfDocument for rendering
  PdfDocument? getDocument(String documentId) {
    return _openDocuments[documentId];
  }

  // Clean up all resources
  Future<void> dispose() async {
    for (final documentId in _openDocuments.keys.toList()) {
      await closeDocument(documentId);
    }
  }
}