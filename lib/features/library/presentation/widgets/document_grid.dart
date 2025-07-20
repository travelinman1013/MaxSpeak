import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/utils/app_theme.dart';
import '../../domain/entities/document.dart';
import 'document_card.dart';

class DocumentGrid extends StatelessWidget {
  const DocumentGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, show placeholder data until we connect to the repository
    final sampleDocuments = _getSampleDocuments();

    if (sampleDocuments.isEmpty) {
      return const EmptyLibraryView();
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
          itemCount: sampleDocuments.length,
          itemBuilder: (context, index) {
            final document = sampleDocuments[index];
            return DocumentCard(
              document: document,
              onTap: () => _openDocument(context, document),
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

  // Sample data for demonstration
  List<Document> _getSampleDocuments() {
    return [
      Document(
        id: '1',
        title: 'Introduction to Machine Learning',
        filePath: '/fake/path/ml_intro.pdf',
        originalFileName: 'ml_intro.pdf',
        totalPages: 150,
        fileSizeBytes: 5242880, // 5MB
        dateAdded: DateTime.now().subtract(const Duration(days: 7)),
        lastOpened: DateTime.now().subtract(const Duration(hours: 2)),
        readingProgress: 0.45,
        currentPage: 68,
      ),
      Document(
        id: '2',
        title: 'Python Programming Guide',
        filePath: '/fake/path/python_guide.pdf',
        originalFileName: 'python_guide.pdf',
        totalPages: 89,
        fileSizeBytes: 3145728, // 3MB
        dateAdded: DateTime.now().subtract(const Duration(days: 3)),
        lastOpened: DateTime.now().subtract(const Duration(days: 3)),
        readingProgress: 0.0,
        currentPage: 1,
      ),
      Document(
        id: '3',
        title: 'Data Structures and Algorithms',
        filePath: '/fake/path/dsa.pdf',
        originalFileName: 'dsa.pdf',
        totalPages: 324,
        fileSizeBytes: 8388608, // 8MB
        dateAdded: DateTime.now().subtract(const Duration(days: 14)),
        lastOpened: DateTime.now().subtract(const Duration(days: 1)),
        readingProgress: 0.12,
        currentPage: 39,
      ),
      Document(
        id: '4',
        title: 'Study Materials - Final Exam',
        filePath: '/fake/path/exam_materials.pdf',
        originalFileName: 'exam_materials.pdf',
        totalPages: 67,
        fileSizeBytes: 2097152, // 2MB
        dateAdded: DateTime.now().subtract(const Duration(days: 1)),
        lastOpened: DateTime.now().subtract(const Duration(minutes: 30)),
        readingProgress: 1.0,
        currentPage: 67,
      ),
    ];
  }
}

class EmptyLibraryView extends StatelessWidget {
  const EmptyLibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
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
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Trigger FAB action
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