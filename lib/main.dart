import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/services/database_service.dart';
import 'core/services/encryption_service.dart';
import 'core/services/settings_service.dart';
import 'core/utils/service_locator.dart';
import 'shared/utils/app_router.dart';
import 'shared/utils/app_theme.dart';
import 'shared/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize core services
  await _initializeServices();
  
  // Setup dependency injection
  setupServiceLocator();
  
  runApp(
    const ProviderScope(
      child: MaxSpeakApp(),
    ),
  );
}

/// Initialize all core services in the correct order
Future<void> _initializeServices() async {
  try {
    // Initialize settings service first (for app preferences)
    await SettingsService.instance.initialize();
    
    // Initialize database service
    await DatabaseService.instance.initialize();
    
    // Initialize encryption service
    await EncryptionService.instance.initialize();
    
    debugPrint('All core services initialized successfully');
  } catch (e) {
    debugPrint('Error initializing services: $e');
    // In a production app, you might want to show an error dialog
    // and potentially exit the app or use fallback modes
  }
}

class MaxSpeakApp extends ConsumerWidget {
  const MaxSpeakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
