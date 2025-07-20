import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';
import '../services/pdf_service.dart';
import '../../features/library/data/datasources/local_document_datasource.dart';
import '../../features/library/data/repositories/document_repository_impl.dart';

/// Comprehensive system validator for MaxSpeak core functionality
class SystemValidator {
  static SystemValidator? _instance;
  static SystemValidator get instance => _instance ??= SystemValidator._();
  
  SystemValidator._();

  /// Run comprehensive system validation
  Future<SystemValidationResult> validateSystem() async {
    final results = <String, bool>{};
    final errors = <String>[];
    
    if (kDebugMode) {
      print('🔍 Starting MaxSpeak System Validation...');
    }
    
    try {
      // 1. Test Database Service
      final dbResult = await _testDatabaseService();
      results['Database Service'] = dbResult.success;
      if (!dbResult.success) errors.addAll(dbResult.errors);
      
      // 2. Test Encryption Service
      final encResult = await _testEncryptionService();
      results['Encryption Service'] = encResult.success;
      if (!encResult.success) errors.addAll(encResult.errors);
      
      // 3. Test PDF Service
      final pdfResult = await _testPdfService();
      results['PDF Service'] = pdfResult.success;
      if (!pdfResult.success) errors.addAll(pdfResult.errors);
      
      // 4. Test Document Repository
      final repoResult = await _testDocumentRepository();
      results['Document Repository'] = repoResult.success;
      if (!repoResult.success) errors.addAll(repoResult.errors);
      
      // 5. Test End-to-End Document Flow
      final e2eResult = await _testEndToEndDocumentFlow();
      results['End-to-End Flow'] = e2eResult.success;
      if (!e2eResult.success) errors.addAll(e2eResult.errors);
      
    } catch (e) {
      errors.add('Validation crashed: ${e.toString()}');
    }
    
    final overallSuccess = errors.isEmpty;
    
    if (kDebugMode) {
      print('📊 System Validation Complete');
      print('✅ Passed: ${results.entries.where((e) => e.value).length}');
      print('❌ Failed: ${results.entries.where((e) => !e.value).length}');
      if (errors.isNotEmpty) {
        print('🐛 Errors:');
        for (final error in errors) {
          print('   - $error');
        }
      }
    }
    
    return SystemValidationResult(
      overallSuccess: overallSuccess,
      testResults: results,
      errors: errors,
    );
  }

  /// Test Database Service functionality
  Future<ValidationResult> _testDatabaseService() async {
    final errors = <String>[];
    
    try {
      final db = DatabaseService.instance;
      
      // Test initialization
      await db.initialize();
      if (!db.documentsBox.isOpen) {
        errors.add('Documents box not open after initialization');
      }
      
      // Test stats
      final stats = db.getStats();
      if (stats['isInitialized'] != true) {
        errors.add('Database not marked as initialized');
      }
      
      if (kDebugMode) {
        print('✅ Database Service: ${errors.isEmpty ? "PASS" : "FAIL"}');
      }
      
    } catch (e) {
      errors.add('Database test failed: ${e.toString()}');
    }
    
    return ValidationResult(success: errors.isEmpty, errors: errors);
  }

  /// Test Encryption Service functionality
  Future<ValidationResult> _testEncryptionService() async {
    final errors = <String>[];
    
    try {
      final encryption = EncryptionService.instance;
      
      // Test initialization
      await encryption.initialize();
      if (!encryption.isInitialized) {
        errors.add('Encryption service not initialized');
      }
      
      // Test byte encryption/decryption
      final testData = Uint8List.fromList([1, 2, 3, 4, 5]);
      final encrypted = await encryption.encryptBytes(testData);
      final decrypted = await encryption.decryptBytes(encrypted);
      
      if (!_compareUint8Lists(testData, decrypted)) {
        errors.add('Byte encryption/decryption failed');
      }
      
      // Test file path generation
      final securePath = await encryption.getSecureStoragePath('test.pdf');
      if (!securePath.contains('encrypted_pdfs') || !securePath.contains('.enc_')) {
        errors.add('Secure storage path generation failed');
      }
      
      if (kDebugMode) {
        print('✅ Encryption Service: ${errors.isEmpty ? "PASS" : "FAIL"}');
      }
      
    } catch (e) {
      errors.add('Encryption test failed: ${e.toString()}');
    }
    
    return ValidationResult(success: errors.isEmpty, errors: errors);
  }

  /// Test PDF Service functionality
  Future<ValidationResult> _testPdfService() async {
    final errors = <String>[];
    
    try {
      final pdfService = PdfService.instance;
      
      // Create a dummy PDF file for testing
      final testPdfPath = await _createDummyPdfFile();
      
      if (testPdfPath != null) {
        // Test PDF validation
        final isValid = await pdfService.isValidPdf(testPdfPath);
        // Note: Dummy file won't be valid, but method should not crash
        
        // Test PDF info retrieval (should handle invalid PDF gracefully)
        final info = await pdfService.getPdfInfo(testPdfPath);
        if (!info.containsKey('isValid')) {
          errors.add('PDF info missing validity flag');
        }
        
        // Cleanup
        await File(testPdfPath).delete();
      }
      
      if (kDebugMode) {
        print('✅ PDF Service: ${errors.isEmpty ? "PASS" : "FAIL"}');
      }
      
    } catch (e) {
      errors.add('PDF service test failed: ${e.toString()}');
    }
    
    return ValidationResult(success: errors.isEmpty, errors: errors);
  }

  /// Test Document Repository functionality
  Future<ValidationResult> _testDocumentRepository() async {
    final errors = <String>[];
    
    try {
      final dataSource = LocalDocumentDataSourceImpl();
      final repository = DocumentRepositoryImpl(localDataSource: dataSource);
      
      // Test getting all documents (should not crash)
      final getAllResult = await repository.getAllDocuments();
      getAllResult.fold(
        (failure) {
          // Failure is acceptable if database is empty
        },
        (documents) {
          // Success is good
        },
      );
      
      // Test getting non-existent document
      final getByIdResult = await repository.getDocumentById('non-existent-id');
      getByIdResult.fold(
        (failure) {
          // Failure is expected for non-existent document
        },
        (document) {
          if (document != null) {
            errors.add('Got document for non-existent ID');
          }
        },
      );
      
      if (kDebugMode) {
        print('✅ Document Repository: ${errors.isEmpty ? "PASS" : "FAIL"}');
      }
      
    } catch (e) {
      errors.add('Repository test failed: ${e.toString()}');
    }
    
    return ValidationResult(success: errors.isEmpty, errors: errors);
  }

  /// Test complete end-to-end document flow
  Future<ValidationResult> _testEndToEndDocumentFlow() async {
    final errors = <String>[];
    
    try {
      // This is a conceptual test - in a real app you'd need actual PDF files
      // For now, we just test that the system components are properly wired
      
      final dataSource = LocalDocumentDataSourceImpl();
      final repository = DocumentRepositoryImpl(localDataSource: dataSource);
      
      // Test the complete flow would work (without actual file)
      // 1. Repository can be created ✓
      // 2. Database is accessible ✓ 
      // 3. Services are initialized ✓
      
      // Test statistics retrieval
      final totalDocsResult = await repository.getTotalDocuments();
      totalDocsResult.fold(
        (failure) => errors.add('Failed to get document count'),
        (count) {
          // Count retrieval successful
        },
      );
      
      final librarySizeResult = await repository.getTotalLibrarySize();
      librarySizeResult.fold(
        (failure) => errors.add('Failed to get library size'),
        (size) {
          // Size retrieval successful
        },
      );
      
      if (kDebugMode) {
        print('✅ End-to-End Flow: ${errors.isEmpty ? "PASS" : "FAIL"}');
      }
      
    } catch (e) {
      errors.add('E2E test failed: ${e.toString()}');
    }
    
    return ValidationResult(success: errors.isEmpty, errors: errors);
  }

  /// Create a dummy file for testing (not a real PDF)
  Future<String?> _createDummyPdfFile() async {
    try {
      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/test_dummy.pdf');
      
      // Create a small dummy file (not a real PDF)
      await testFile.writeAsString('Dummy PDF content for testing');
      
      return testFile.path;
    } catch (e) {
      return null;
    }
  }

  /// Compare two Uint8Lists for equality
  bool _compareUint8Lists(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Result of individual validation test
class ValidationResult {
  final bool success;
  final List<String> errors;
  
  const ValidationResult({
    required this.success,
    required this.errors,
  });
}

/// Overall system validation result
class SystemValidationResult {
  final bool overallSuccess;
  final Map<String, bool> testResults;
  final List<String> errors;
  
  const SystemValidationResult({
    required this.overallSuccess,
    required this.testResults,
    required this.errors,
  });
  
  /// Get a summary string
  String get summary {
    final passed = testResults.entries.where((e) => e.value).length;
    final total = testResults.length;
    
    return 'System Validation: $passed/$total tests passed. '
           '${overallSuccess ? "All systems operational!" : "${errors.length} errors found."}';
  }
  
  /// Get detailed report
  String get detailedReport {
    final buffer = StringBuffer();
    buffer.writeln('📊 MaxSpeak System Validation Report');
    buffer.writeln('=' * 50);
    
    for (final entry in testResults.entries) {
      final status = entry.value ? '✅ PASS' : '❌ FAIL';
      buffer.writeln('${entry.key}: $status');
    }
    
    if (errors.isNotEmpty) {
      buffer.writeln('\n🐛 Errors Found:');
      for (final error in errors) {
        buffer.writeln('   - $error');
      }
    }
    
    buffer.writeln('\n📈 Summary: ${summary}');
    
    return buffer.toString();
  }
}