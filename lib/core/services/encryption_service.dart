import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class EncryptionService {
  static const String _keyStorageKey = 'maxspeak_encryption_key';
  static const String _ivStorageKey = 'maxspeak_encryption_iv';
  static const int _keyLength = 32; // 256 bits
  static const int _ivLength = 16; // 128 bits
  
  static EncryptionService? _instance;
  static EncryptionService get instance => _instance ??= EncryptionService._();
  
  EncryptionService._();
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  encrypt_lib.Encrypter? _encrypter;
  encrypt_lib.IV? _iv;
  bool _isInitialized = false;

  /// Initialize the encryption service with secure key generation
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Get or generate encryption key
      final key = await _getOrGenerateKey();
      
      // Get or generate IV
      final iv = await _getOrGenerateIV();
      
      // Initialize encrypter
      _encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(key));
      _iv = iv;
      
      _isInitialized = true;
      
      if (kDebugMode) {
        print('Encryption service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing encryption service: $e');
      }
      rethrow;
    }
  }

  /// Encrypt a file and save it to a new location
  Future<String> encryptFile(String inputPath, String outputPath) async {
    if (!_isInitialized) {
      throw Exception('Encryption service not initialized');
    }
    
    try {
      final inputFile = File(inputPath);
      if (!await inputFile.exists()) {
        throw Exception('Input file does not exist: $inputPath');
      }

      // Read file as bytes
      final fileBytes = await inputFile.readAsBytes();
      
      // Encrypt the file content
      final encrypted = _encrypter!.encryptBytes(fileBytes, iv: _iv!);
      
      // Create output directory if it doesn't exist
      final outputFile = File(outputPath);
      await outputFile.parent.create(recursive: true);
      
      // Write encrypted data
      await outputFile.writeAsBytes(encrypted.bytes);
      
      if (kDebugMode) {
        print('File encrypted successfully: $inputPath -> $outputPath');
      }
      
      return outputPath;
    } catch (e) {
      if (kDebugMode) {
        print('Error encrypting file: $e');
      }
      rethrow;
    }
  }

  /// Decrypt a file and save it to a new location
  Future<String> decryptFile(String inputPath, String outputPath) async {
    if (!_isInitialized) {
      throw Exception('Encryption service not initialized');
    }
    
    try {
      final inputFile = File(inputPath);
      if (!await inputFile.exists()) {
        throw Exception('Input file does not exist: $inputPath');
      }

      // Read encrypted bytes
      final encryptedBytes = await inputFile.readAsBytes();
      
      // Decrypt the file content
      final decrypted = _encrypter!.decryptBytes(
        encrypt_lib.Encrypted(encryptedBytes),
        iv: _iv!,
      );
      
      // Create output directory if it doesn't exist
      final outputFile = File(outputPath);
      await outputFile.parent.create(recursive: true);
      
      // Write decrypted data
      await outputFile.writeAsBytes(decrypted);
      
      if (kDebugMode) {
        print('File decrypted successfully: $inputPath -> $outputPath');
      }
      
      return outputPath;
    } catch (e) {
      if (kDebugMode) {
        print('Error decrypting file: $e');
      }
      rethrow;
    }
  }

  /// Encrypt bytes directly (for smaller data)
  Future<Uint8List> encryptBytes(Uint8List data) async {
    if (!_isInitialized) {
      throw Exception('Encryption service not initialized');
    }
    
    try {
      final encrypted = _encrypter!.encryptBytes(data, iv: _iv!);
      return encrypted.bytes;
    } catch (e) {
      if (kDebugMode) {
        print('Error encrypting bytes: $e');
      }
      rethrow;
    }
  }

  /// Decrypt bytes directly (for smaller data)
  Future<Uint8List> decryptBytes(Uint8List encryptedData) async {
    if (!_isInitialized) {
      throw Exception('Encryption service not initialized');
    }
    
    try {
      final decrypted = _encrypter!.decryptBytes(
        encrypt_lib.Encrypted(encryptedData),
        iv: _iv!,
      );
      return Uint8List.fromList(decrypted);
    } catch (e) {
      if (kDebugMode) {
        print('Error decrypting bytes: $e');
      }
      rethrow;
    }
  }

  /// Generate a secure file path for encrypted storage
  Future<String> getSecureStoragePath(String originalFileName) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final secureDir = Directory('${documentsDir.path}/encrypted_pdfs');
    
    if (!await secureDir.exists()) {
      await secureDir.create(recursive: true);
    }
    
    // Generate unique filename with timestamp and hash
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = sha256.convert(utf8.encode(originalFileName)).toString().substring(0, 8);
    final extension = originalFileName.split('.').last;
    
    return '${secureDir.path}/${timestamp}_$hash.enc_$extension';
  }

  /// Check if a file is encrypted by this service
  bool isEncryptedFile(String filePath) {
    return filePath.contains('.enc_');
  }

  /// Get the original extension from an encrypted file name
  String? getOriginalExtension(String encryptedPath) {
    final regex = RegExp(r'\.enc_(.+)$');
    final match = regex.firstMatch(encryptedPath);
    return match?.group(1);
  }

  /// Get or generate encryption key
  Future<encrypt_lib.Key> _getOrGenerateKey() async {
    try {
      // Try to get existing key
      final keyString = await _secureStorage.read(key: _keyStorageKey);
      
      if (keyString != null) {
        final keyBytes = base64.decode(keyString);
        if (keyBytes.length == _keyLength) {
          return encrypt_lib.Key(Uint8List.fromList(keyBytes));
        }
      }
      
      // Generate new key
      final random = Random.secure();
      final keyBytes = Uint8List(_keyLength);
      for (int i = 0; i < _keyLength; i++) {
        keyBytes[i] = random.nextInt(256);
      }
      
      // Store the key securely
      await _secureStorage.write(
        key: _keyStorageKey,
        value: base64.encode(keyBytes),
      );
      
      if (kDebugMode) {
        print('Generated new encryption key');
      }
      
      return encrypt_lib.Key(keyBytes);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting/generating encryption key: $e');
      }
      rethrow;
    }
  }

  /// Get or generate initialization vector
  Future<encrypt_lib.IV> _getOrGenerateIV() async {
    try {
      // Try to get existing IV
      final ivString = await _secureStorage.read(key: _ivStorageKey);
      
      if (ivString != null) {
        final ivBytes = base64.decode(ivString);
        if (ivBytes.length == _ivLength) {
          return encrypt_lib.IV(Uint8List.fromList(ivBytes));
        }
      }
      
      // Generate new IV
      final random = Random.secure();
      final ivBytes = Uint8List(_ivLength);
      for (int i = 0; i < _ivLength; i++) {
        ivBytes[i] = random.nextInt(256);
      }
      
      // Store the IV securely
      await _secureStorage.write(
        key: _ivStorageKey,
        value: base64.encode(ivBytes),
      );
      
      if (kDebugMode) {
        print('Generated new encryption IV');
      }
      
      return encrypt_lib.IV(ivBytes);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting/generating encryption IV: $e');
      }
      rethrow;
    }
  }

  /// Clear all encryption keys (for testing or reset)
  Future<void> clearKeys() async {
    try {
      await _secureStorage.delete(key: _keyStorageKey);
      await _secureStorage.delete(key: _ivStorageKey);
      
      _encrypter = null;
      _iv = null;
      _isInitialized = false;
      
      if (kDebugMode) {
        print('Encryption keys cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing encryption keys: $e');
      }
      rethrow;
    }
  }

  /// Get encryption status
  bool get isInitialized => _isInitialized;
  
  /// Get encryption info for debugging
  Map<String, dynamic> getEncryptionInfo() {
    return {
      'isInitialized': _isInitialized,
      'hasEncrypter': _encrypter != null,
      'hasIV': _iv != null,
      'keyLength': _keyLength,
      'ivLength': _ivLength,
    };
  }
}