import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';

class PdfService {
  static PdfService? _instance;
  static PdfService get instance => _instance ??= PdfService._();
  
  PdfService._();

  /// Get the number of pages in a PDF file
  Future<int> getPageCount(String filePath) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        throw Exception('PDF file not found: $filePath');
      }

      final document = await PdfDocument.openFile(filePath);
      final pageCount = document.pagesCount;
      
      // Close the document to free memory
      await document.close();
      
      if (kDebugMode) {
        print('PDF page count: $pageCount for $filePath');
      }
      
      return pageCount;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting PDF page count: $e');
      }
      
      // Return 0 if we can't determine page count
      // The document can still be added, page count will be updated later
      return 0;
    }
  }

  /// Validate if a file is a valid PDF
  Future<bool> isValidPdf(String filePath) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        return false;
      }

      // Try to open the PDF document
      final document = await PdfDocument.openFile(filePath);
      final isValid = document.pagesCount > 0;
      
      // Close the document
      await document.close();
      
      return isValid;
    } catch (e) {
      if (kDebugMode) {
        print('PDF validation failed: $e');
      }
      return false;
    }
  }

  /// Get basic PDF information
  Future<Map<String, dynamic>> getPdfInfo(String filePath) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        throw Exception('PDF file not found: $filePath');
      }

      final document = await PdfDocument.openFile(filePath);
      final fileStats = await file.stat();
      
      final info = {
        'pageCount': document.pagesCount,
        'fileSizeBytes': fileStats.size,
        'lastModified': fileStats.modified,
        'isValid': document.pagesCount > 0,
      };
      
      // Close the document
      await document.close();
      
      if (kDebugMode) {
        print('PDF info: $info');
      }
      
      return info;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting PDF info: $e');
      }
      
      // Return minimal info if PDF can't be analyzed
      final file = File(filePath);
      final fileStats = await file.stat();
      
      return {
        'pageCount': 0,
        'fileSizeBytes': fileStats.size,
        'lastModified': fileStats.modified,
        'isValid': false,
        'error': e.toString(),
      };
    }
  }

  /// Generate a thumbnail from the first page of a PDF
  Future<String?> generateThumbnail(String filePath, String documentId) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        throw Exception('PDF file not found: $filePath');
      }

      // Create thumbnails directory
      final appDir = await getApplicationDocumentsDirectory();
      final thumbnailsDir = Directory('${appDir.path}/thumbnails');
      if (!await thumbnailsDir.exists()) {
        await thumbnailsDir.create(recursive: true);
      }

      final outputPath = '${thumbnailsDir.path}/$documentId.png';

      // Open the PDF document
      final document = await PdfDocument.openFile(filePath);
      
      if (document.pagesCount == 0) {
        await document.close();
        throw Exception('PDF has no pages');
      }

      // Get the first page
      final page = await document.getPage(1);
      
      // Render the page as an image
      // Scale down for thumbnail (200px width)
      const thumbnailWidth = 200.0;
      final aspectRatio = page.width / page.height;
      final thumbnailHeight = thumbnailWidth / aspectRatio;
      
      final pageImage = await page.render(
        width: thumbnailWidth,
        height: thumbnailHeight,
        format: PdfPageImageFormat.png,
      );
      
      // Save the image
      final outputFile = File(outputPath);
      if (pageImage?.bytes != null) {
        await outputFile.writeAsBytes(pageImage!.bytes!);
      } else {
        throw Exception('Failed to render page image');
      }
      
      // Clean up
      page.close();
      await document.close();
      
      if (kDebugMode) {
        print('Thumbnail generated successfully: $outputPath');
      }
      
      return outputPath;
    } catch (e) {
      if (kDebugMode) {
        print('Error generating thumbnail: $e');
      }
      return null;
    }
  }

  /// Clean up old thumbnails to save space
  Future<void> cleanupOldThumbnails(List<String> activeDocumentIds) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final thumbnailsDir = Directory('${appDir.path}/thumbnails');
      
      if (!await thumbnailsDir.exists()) {
        return;
      }

      final thumbnailFiles = await thumbnailsDir.list().toList();
      
      for (final entity in thumbnailFiles) {
        if (entity is File && entity.path.endsWith('.png')) {
          final fileName = entity.path.split('/').last;
          final documentId = fileName.replaceAll('.png', '');
          
          // Delete thumbnail if document no longer exists
          if (!activeDocumentIds.contains(documentId)) {
            await entity.delete();
            if (kDebugMode) {
              print('Deleted old thumbnail: $fileName');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning up thumbnails: $e');
      }
    }
  }

  /// Get thumbnail file path for a document
  Future<String?> getThumbnailPath(String documentId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final thumbnailPath = '${appDir.path}/thumbnails/$documentId.png';
      
      final file = File(thumbnailPath);
      if (await file.exists()) {
        return thumbnailPath;
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting thumbnail path: $e');
      }
      return null;
    }
  }
}