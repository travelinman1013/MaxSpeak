import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../features/library/presentation/pages/library_page.dart';
import '../../features/reader/presentation/pages/reader_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/privacy_policy_page.dart';
import '../../features/settings/presentation/pages/terms_of_service_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppConstants.libraryRoute,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppConstants.libraryRoute,
        name: 'library',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LibraryPage(),
        ),
      ),
      GoRoute(
        path: AppConstants.readerRoute,
        name: 'reader',
        pageBuilder: (context, state) {
          final documentId = state.extra as String?;
          return MaterialPage(
            key: state.pageKey,
            child: ReaderPage(documentId: documentId ?? ''),
          );
        },
      ),
      GoRoute(
        path: AppConstants.settingsRoute,
        name: 'settings',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SettingsPage(),
        ),
      ),
      GoRoute(
        path: AppConstants.statsRoute,
        name: 'stats',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const StatsPage(),
        ),
      ),
      GoRoute(
        path: AppConstants.premiumRoute,
        name: 'premium',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const PremiumPage(),
        ),
      ),
      GoRoute(
        path: '/privacy-policy',
        name: 'privacy-policy',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const PrivacyPolicyPage(),
        ),
      ),
      GoRoute(
        path: '/terms-of-service',
        name: 'terms-of-service',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const TermsOfServicePage(),
        ),
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: ErrorPage(error: state.error.toString()),
    ),
  );
});

// Placeholder pages - will be implemented in their respective features
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: const Center(child: Text('Stats Page - Coming Soon')),
    );
  }
}

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: const Center(child: Text('Premium Page - Coming Soon')),
    );
  }
}

class ErrorPage extends StatelessWidget {
  final String error;
  
  const ErrorPage({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.libraryRoute),
              child: const Text('Go to Library'),
            ),
          ],
        ),
      ),
    );
  }
}
