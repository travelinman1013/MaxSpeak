import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/utils/app_theme.dart';
import '../providers/document_provider.dart';
import '../widgets/document_grid.dart';
import '../widgets/library_app_bar.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/add_document_fab.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize the documents provider when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(documentsProvider.notifier).initialize();
    });
  }

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    switch (index) {
      case 0: // Library - already here
        break;
      case 1: // Now Playing
        // TODO: Navigate to now playing or show bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Now Playing - Coming Soon')),
        );
        break;
      case 2: // Stats
        context.go(AppConstants.statsRoute);
        break;
      case 3: // Premium
        context.go(AppConstants.premiumRoute);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const LibraryAppBar(),
      body: const LibraryBody(),
      floatingActionButton: const AddDocumentFab(),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class LibraryBody extends ConsumerWidget {
  const LibraryBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Your Library',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Document Grid
          const Expanded(
            child: DocumentGrid(),
          ),
        ],
      ),
    );
  }
}