import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/library/data/models/document_model.dart';

class DatabaseService {
  static const String _documentsBoxName = 'documents';
  static const String _encryptionKeyBoxName = 'encryption_keys';
  
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();
  
  DatabaseService._();
  
  late Box<DocumentModel> _documentsBox;
  late Box<String> _encryptionKeysBox;
  
  bool _isInitialized = false;
  
  /// Initialize Hive database with encryption
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize Hive
      if (!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        await Hive.initFlutter(directory.path);
      } else {
        await Hive.initFlutter();
      }
      
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(DocumentModelAdapter());
      }
      
      // Open boxes
      _documentsBox = await Hive.openBox<DocumentModel>(_documentsBoxName);
      _encryptionKeysBox = await Hive.openBox<String>(_encryptionKeyBoxName);
      
      _isInitialized = true;
      
      if (kDebugMode) {
        print('Database initialized successfully');
        print('Documents count: ${_documentsBox.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing database: $e');
      }
      rethrow;
    }
  }
  
  /// Get the documents box
  Box<DocumentModel> get documentsBox {
    if (!_isInitialized) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _documentsBox;
  }
  
  /// Get the encryption keys box
  Box<String> get encryptionKeysBox {
    if (!_isInitialized) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _encryptionKeysBox;
  }
  
  /// Close all boxes and cleanup
  Future<void> close() async {
    if (!_isInitialized) return;
    
    await _documentsBox.close();
    await _encryptionKeysBox.close();
    await Hive.close();
    
    _isInitialized = false;
    
    if (kDebugMode) {
      print('Database closed');
    }
  }
  
  /// Clear all data (for testing or user data reset)
  Future<void> clearAll() async {
    if (!_isInitialized) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    
    await _documentsBox.clear();
    await _encryptionKeysBox.clear();
    
    if (kDebugMode) {
      print('All database data cleared');
    }
  }
  
  /// Get database statistics
  Map<String, dynamic> getStats() {
    if (!_isInitialized) {
      return {'error': 'Database not initialized'};
    }
    
    return {
      'isInitialized': _isInitialized,
      'documentsCount': _documentsBox.length,
      'encryptionKeysCount': _encryptionKeysBox.length,
      'documentsBoxPath': _documentsBox.path,
    };
  }
}

