import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pdf_viewer_provider.dart';

class PdfNavigationControls extends ConsumerWidget {
  const PdfNavigationControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfViewerProvider);

    if (!state.isLoaded) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          // Previous page button
          IconButton(
            onPressed: state.canGoToPreviousPage
                ? () => ref.read(pdfViewerProvider.notifier).previousPage()
                : null,
            icon: const Icon(
              Icons.chevron_left,
              color: Colors.white,
              size: 28,
            ),
          ),

          // Page info
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Page ${state.currentPage} of ${state.totalPages}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: state.progress,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ],
            ),
          ),

          // Next page button
          IconButton(
            onPressed: state.canGoToNextPage
                ? () => ref.read(pdfViewerProvider.notifier).nextPage()
                : null,
            icon: const Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 28,
            ),
          ),

          // Page jump button
          IconButton(
            onPressed: () => _showPageJumpDialog(context, ref, state),
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showPageJumpDialog(BuildContext context, WidgetRef ref, PdfViewerState state) {
    final pageController = TextEditingController(text: state.currentPage.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Go to Page',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: pageController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter page number (1-${state.totalPages})',
            hintStyle: const TextStyle(color: Colors.white54),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              final pageNumber = int.tryParse(pageController.text);
              if (pageNumber != null && 
                  pageNumber >= 1 && 
                  pageNumber <= state.totalPages) {
                ref.read(pdfViewerProvider.notifier).goToPage(pageNumber);
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Go',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}
