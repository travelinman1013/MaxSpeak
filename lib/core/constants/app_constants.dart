class AppConstants {
  // App Info
  static const String appName = 'MaxSpeak';
  static const String appVersion = '0.1.0';
  
  // Storage Keys
  static const String documentsBox = 'documents_box';
  static const String settingsBox = 'settings_box';
  static const String readingProgressBox = 'reading_progress_box';
  
  // Encryption
  static const String encryptionKey = 'MAXSPEAK_ENCRYPTION_KEY'; // In production, use secure key generation
  
  // TTS Settings
  static const double minSpeechRate = 0.5;
  static const double maxSpeechRate = 3.0;
  static const double defaultSpeechRate = 1.0;
  static const double speechRateStep = 0.25;
  
  // UI Settings
  static const int gridCrossAxisCount = 2;
  static const int gridCrossAxisCountTablet = 3;
  static const double minTouchTargetSize = 48.0;
  
  // File Size Limits
  static const int maxPdfSizeMB = 100;
  static const int maxPdfSizeBytes = maxPdfSizeMB * 1024 * 1024;
  
  // Animation Durations
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration normalAnimationDuration = Duration(milliseconds: 250);
  static const Duration slowAnimationDuration = Duration(milliseconds: 350);
  
  // Page Routes
  static const String libraryRoute = '/';
  static const String readerRoute = '/reader';
  static const String settingsRoute = '/settings';
  static const String statsRoute = '/stats';
  static const String premiumRoute = '/premium';
  
  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String pdfTooLargeError = 'PDF file is too large (max ${maxPdfSizeMB}MB)';
  static const String pdfCorruptedError = 'PDF file appears to be corrupted';
  static const String noInternetError = 'No internet connection available';
  
  // Success Messages
  static const String documentAddedSuccess = 'Document added successfully';
  static const String documentDeletedSuccess = 'Document deleted successfully';
  static const String progressSavedSuccess = 'Reading progress saved';
}