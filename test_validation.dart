import 'dart:io';
import 'package:flutter/foundation.dart';
import 'lib/core/utils/system_validator.dart';
import 'lib/core/services/database_service.dart';
import 'lib/core/services/encryption_service.dart';

/// Standalone validation script to test MaxSpeak system
void main() async {
  print('🚀 MaxSpeak System Validation Starting...\n');
  
  try {
    // Initialize core services first
    await _initializeServices();
    
    // Run comprehensive validation
    final validator = SystemValidator.instance;
    final result = await validator.validateSystem();
    
    // Print results
    print('\n' + result.detailedReport);
    
    // Exit with appropriate code
    exit(result.overallSuccess ? 0 : 1);
    
  } catch (e, stackTrace) {
    print('❌ Validation failed with error: $e');
    if (kDebugMode) {
      print('Stack trace: $stackTrace');
    }
    exit(1);
  }
}

/// Initialize core services for testing
Future<void> _initializeServices() async {
  try {
    print('⚙️ Initializing core services...');
    
    // Initialize database service
    await DatabaseService.instance.initialize();
    print('✅ Database service initialized');
    
    // Initialize encryption service  
    await EncryptionService.instance.initialize();
    print('✅ Encryption service initialized');
    
    print('✅ All core services initialized successfully\n');
    
  } catch (e) {
    print('❌ Failed to initialize services: $e');
    rethrow;
  }
}