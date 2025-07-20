import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import '../providers/pdf_viewer_provider.dart';

class PdfViewerWidget extends ConsumerStatefulWidget {
  final String documentId;
  final String filePath;

  const PdfViewerWidget({
    super.key,
    required this.documentId,
    required this.filePath,
  });

  @override
  ConsumerState<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends ConsumerState<PdfViewerWidget> {
  PdfController? _pdfController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDocument();
    });
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  Future<void> _loadDocument() async {
    await ref.read(pdfViewerProvider.notifier).loadDocument(
      widget.documentId,
      widget.filePath,
    );
  }

  void _initializePdfController() {
    final state = ref.read(pdfViewerProvider);
    if (state.document != null && _pdfController == null) {
      _pdfController = PdfController(
        document: Future.value(state.document!),
        initialPage: state.currentPage,
      );

      // Note: Page change listening handled by onPageChanged callback
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pdfViewerProvider);

    if (state.isLoading) {
      return _buildLoadingView(state);
    }

    if (state.error != null) {
      return _buildErrorView(state.error!);
    }

    if (!state.isLoaded || state.document == null) {
      return _buildEmptyView();
    }

    // Initialize PDF controller when document is loaded
    if (_pdfController == null) {
      _initializePdfController();
    }

    return _buildPdfView();
  }

  Widget _buildLoadingView(PdfViewerState state) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
            const SizedBox(height: 24),
            const Text(
              'Loading PDF...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(state.loadingProgress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                'Error Loading PDF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadDocument,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: Colors.white54,
            ),
            SizedBox(height: 24),
            Text(
              'No Document Loaded',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfView() {
    if (_pdfController == null) {
      return _buildLoadingView(ref.watch(pdfViewerProvider));
    }

    return Container(
      color: Colors.black,
      child: PdfView(
        controller: _pdfController!,
        scrollDirection: Axis.vertical,
        pageSnapping: true,
        physics: const BouncingScrollPhysics(),
        onDocumentLoaded: (document) {
          // Document loaded successfully
        },
        onPageChanged: (page) {
          ref.read(pdfViewerProvider.notifier).goToPage(page);
        },
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        // pageDecoration removed in newer pdfx versions
      ),
    );
  }
}