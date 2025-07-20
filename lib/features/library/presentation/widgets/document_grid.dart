import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/utils/app_theme.dart';
import '../../domain/entities/document.dart';
import '../providers/document_provider.dart';
import 'document_card.dart';

class DocumentGrid extends ConsumerWidget {
  const DocumentGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsState = ref.watch(documentsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    
    // Show loading state
    if (documentsState.isLoading && !documentsState.isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppTheme.spacingM),
            Text('Loading your library...'),
          ],
        ),
      );
    }
    
    // Show error state
    if (documentsState.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                'Error Loading Library',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                documentsState.error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppTheme.spacingL),
              ElevatedButton(
                onPressed: () {
                  ref.read(documentsProvider.notifier).loadDocuments();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Filter documents based on search query
    final documents = searchQuery.isEmpty
        ? documentsState.documents
        : documentsState.documents.where((doc) {
            final query = searchQuery.toLowerCase();
            return doc.title.toLowerCase().contains(query) ||
                   doc.originalFileName.toLowerCase().contains(query);
          }).toList();

    // Show empty state
    if (documents.isEmpty) {
      return EmptyLibraryView(
        isSearching: searchQuery.isNotEmpty,
        searchQuery: searchQuery,
        onClearSearch: () => ref.read(searchQueryProvider.notifier).state = '',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
        
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.65, // Slightly taller than square for book-like appearance
            crossAxisSpacing: AppTheme.spacingM,
            mainAxisSpacing: AppTheme.spacingM,
          ),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final document = documents[index];
            return DocumentCard(
              document: document,
              onTap: () => _openDocument(context, document),
              onDelete: () => _deleteDocument(context, ref, document),
            );
          },
        );
      },
    );
  }

  int _calculateCrossAxisCount(double width) {
    if (width > 800) return 4; // Large tablets/desktop
    if (width > 600) return 3; // Small tablets
    return 2; // Phones
  }

  void _openDocument(BuildContext context, Document document) {
    context.go(AppConstants.readerRoute, extra: document.id);
  }

  Future<void> _deleteDocument(BuildContext context, WidgetRef ref, Document document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "${document.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref.read(documentsProvider.notifier).removeDocument(document.id);
      
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppConstants.documentDeletedSuccess}: ${document.title}'),
              backgroundColor: AppTheme.secondaryColor,
            ),
          );
        } else {
          final error = ref.read(documentsProvider).error ?? 'Failed to delete document';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

}

class EmptyLibraryView extends StatelessWidget {
  final bool isSearching;
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const EmptyLibraryView({
    super.key,
    this.isSearching = false,
    this.searchQuery = '',
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    if (isSearching) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: AppTheme.spacingL),
              Text(
                'No Results Found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                'No documents match "$searchQuery".\nTry adjusting your search terms.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              if (onClearSearch != null)
                ElevatedButton(
                  onPressed: onClearSearch,
                  child: const Text('Clear Search'),
                ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Your Library is Empty',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Tap the + button to add your first document and start your reading journey.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            ElevatedButton.icon(
              onPressed: () {
                // Could trigger FAB action via callback if needed
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Document'),
            ),
          ],
        ),
      ),
    );
  }
}
