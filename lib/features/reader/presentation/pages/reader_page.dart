import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../library/domain/usecases/get_all_documents.dart';
import '../../../library/presentation/providers/document_provider.dart';
import '../providers/pdf_viewer_provider.dart';
import '../providers/text_selection_provider.dart';
import '../providers/reader_tts_provider.dart';
import '../widgets/pdf_viewer_widget.dart';
import '../widgets/pdf_navigation_controls.dart';
import '../widgets/text_selection_overlay.dart' as reader_widgets;
import '../widgets/tts_control_overlay.dart';

class ReaderPage extends ConsumerStatefulWidget {
  final String documentId;
  
  const ReaderPage({super.key, required this.documentId});

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  String? documentPath;
  String? documentTitle;
  bool showControls = true;

  @override
  void initState() {
    super.initState();
    _loadDocumentInfo();
    
    // Initialize TTS when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(readerTtsProvider.notifier).initialize();
    });
  }

  Future<void> _loadDocumentInfo() async {
    // Get document info from the library
    final documentsResult = await ref.read(getAllDocumentsProvider).call(NoParams());
    documentsResult.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading document: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      (documents) {
        final document = documents.firstWhere(
          (doc) => doc.id == widget.documentId,
          orElse: () => throw Exception('Document not found'),
        );
        
        if (mounted) {
          setState(() {
            documentPath = document.filePath;
            documentTitle = document.title;
          });
        }
      },
    );
  }

  void _toggleControls() {
    setState(() {
      showControls = !showControls;
    });
  }

  void _toggleFullscreen() {
    setState(() {
      showControls = false;
    });
    
    // Hide system UI for fullscreen reading
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersive,
      overlays: [],
    );
  }

  void _exitFullscreen() {
    setState(() {
      showControls = true;
    });
    
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  @override
  void dispose() {
    // Ensure system UI is restored when leaving
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    
    // Close the PDF document
    ref.read(pdfViewerProvider.notifier).closeDocument();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (documentPath == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: showControls ? _buildAppBar() : null,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // PDF Viewer
            PdfViewerWidget(
              documentId: widget.documentId,
              filePath: documentPath!,
            ),
            
            // TTS Control Overlay
            if (showControls) const TtsControlOverlay(),
            
            // Text Selection Overlay
            const reader_widgets.TextSelectionOverlay(),
            
            // Fullscreen toggle button (always visible)
            Positioned(
              top: showControls ? null : 50,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  onPressed: showControls ? _toggleFullscreen : _exitFullscreen,
                  icon: Icon(
                    showControls ? Icons.fullscreen : Icons.fullscreen_exit,
                    color: Colors.white,
                    size: 28,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    shape: const CircleBorder(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: showControls ? const PdfNavigationControls() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final state = ref.watch(pdfViewerProvider);
    
    return AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            documentTitle ?? 'Reader',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (state.isLoaded)
            Text(
              '${state.currentPage} of ${state.totalPages}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
        ],
      ),
      actions: [
        // Select all text button
        IconButton(
          onPressed: () {
            // For now, simulate selecting entire page
            // In a real implementation, this would extract text from the current PDF page
            ref.read(textSelectionProvider.notifier).selectEntirePage(
              widget.documentId,
              1, // Current page - should get from PDF viewer state
              'This is sample text from the PDF page. In a real implementation, this would be extracted from the actual PDF content using a text extraction library.',
            );
          },
          icon: const Icon(Icons.select_all),
          tooltip: 'Select All Text',
        ),
        
        // TTS button
        Consumer(
          builder: (context, ref, child) {
            final ttsState = ref.watch(readerTtsProvider);
            return IconButton(
              onPressed: () {
                if (ttsState.isPlaying) {
                  ref.read(readerTtsProvider.notifier).pause();
                } else {
                  final selection = ref.read(textSelectionProvider).currentSelection;
                  if (selection != null) {
                    ref.read(readerTtsProvider.notifier).speakSelection(selection);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Select text first to start speaking'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              icon: Icon(
                ttsState.isPlaying ? Icons.pause : Icons.volume_up_outlined
              ),
              tooltip: ttsState.isPlaying ? 'Pause TTS' : 'Text-to-Speech',
            );
          },
        ),
        
        // Settings button
        IconButton(
          onPressed: () => _showSettingsBottomSheet(),
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Reader Settings',
        ),
      ],
    );
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reader Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Zoom level
            Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(pdfViewerProvider);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Zoom Level',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Slider(
                      value: state.zoomLevel,
                      min: 0.5,
                      max: 3.0,
                      divisions: 10,
                      activeColor: Colors.orange,
                      onChanged: (value) {
                        ref.read(pdfViewerProvider.notifier).setZoomLevel(value);
                      },
                    ),
                    Text(
                      '${(state.zoomLevel * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Reading mode info
            const ListTile(
              leading: Icon(Icons.info_outline, color: Colors.orange),
              title: Text(
                'Tap screen to toggle controls',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Use fullscreen for distraction-free reading',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}