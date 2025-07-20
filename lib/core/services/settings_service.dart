import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _hapticFeedbackKey = 'haptic_feedback';
  static const String _readingSoundsKey = 'reading_sounds';
  static const String _autoSaveProgressKey = 'auto_save_progress';
  static const String _syncAcrossDevicesKey = 'sync_across_devices';
  static const String _readingFontSizeKey = 'reading_font_size';
  
  static SettingsService? _instance;
  static SettingsService get instance => _instance ??= SettingsService._();
  
  SettingsService._();
  
  SharedPreferences? _prefs;
  
  /// Initialize the settings service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      if (kDebugMode) {
        print('Settings service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing settings service: $e');
      }
      rethrow;
    }
  }
  
  /// Get haptic feedback setting
  bool get hapticFeedback => _prefs?.getBool(_hapticFeedbackKey) ?? true;
  
  /// Set haptic feedback setting
  Future<void> setHapticFeedback(bool enabled) async {
    await _prefs?.setBool(_hapticFeedbackKey, enabled);
    if (kDebugMode) {
      print('Haptic feedback set to: $enabled');
    }
  }
  
  /// Get reading sounds setting
  bool get readingSounds => _prefs?.getBool(_readingSoundsKey) ?? false;
  
  /// Set reading sounds setting
  Future<void> setReadingSounds(bool enabled) async {
    await _prefs?.setBool(_readingSoundsKey, enabled);
    if (kDebugMode) {
      print('Reading sounds set to: $enabled');
    }
  }
  
  /// Get auto-save progress setting
  bool get autoSaveProgress => _prefs?.getBool(_autoSaveProgressKey) ?? true;
  
  /// Set auto-save progress setting
  Future<void> setAutoSaveProgress(bool enabled) async {
    await _prefs?.setBool(_autoSaveProgressKey, enabled);
    if (kDebugMode) {
      print('Auto-save progress set to: $enabled');
    }
  }
  
  /// Get sync across devices setting
  bool get syncAcrossDevices => _prefs?.getBool(_syncAcrossDevicesKey) ?? false;
  
  /// Set sync across devices setting
  Future<void> setSyncAcrossDevices(bool enabled) async {
    await _prefs?.setBool(_syncAcrossDevicesKey, enabled);
    if (kDebugMode) {
      print('Sync across devices set to: $enabled');
    }
  }
  
  /// Get reading font size
  double get readingFontSize => _prefs?.getDouble(_readingFontSizeKey) ?? 16.0;
  
  /// Set reading font size
  Future<void> setReadingFontSize(double size) async {
    await _prefs?.setDouble(_readingFontSizeKey, size);
    if (kDebugMode) {
      print('Reading font size set to: $size');
    }
  }
  
  /// Reset all settings to defaults
  Future<void> resetAllSettings() async {
    try {
      await _prefs?.remove(_hapticFeedbackKey);
      await _prefs?.remove(_readingSoundsKey);
      await _prefs?.remove(_autoSaveProgressKey);
      await _prefs?.remove(_syncAcrossDevicesKey);
      await _prefs?.remove(_readingFontSizeKey);
      
      if (kDebugMode) {
        print('All settings reset to defaults');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting settings: $e');
      }
      rethrow;
    }
  }
  
  /// Get all settings as a map (for debugging or export)
  Map<String, dynamic> getAllSettings() {
    return {
      'hapticFeedback': hapticFeedback,
      'readingSounds': readingSounds,
      'autoSaveProgress': autoSaveProgress,
      'syncAcrossDevices': syncAcrossDevices,
      'readingFontSize': readingFontSize,
    };
  }
  
  /// Check if settings service is ready
  bool get isInitialized => _prefs != null;
}