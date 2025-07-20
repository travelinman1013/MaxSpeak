import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/text_selection_provider.dart';
import '../providers/reader_tts_provider.dart';

class TextSelectionOverlay extends ConsumerWidget {
  const TextSelectionOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(textSelectionProvider);
    final ttsState = ref.watch(readerTtsProvider);

    if (!selectionState.showSelectionMenu || !selectionState.hasSelection) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 100, // Position above navigation controls
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selection info
              Row(
                children: [
                  const Icon(Icons.text_fields, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${selectionState.wordCount} words selected',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '~${selectionState.estimatedTtsSeconds}s',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Selected text preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  selectionState.selectedText.length > 100
                      ? '${selectionState.selectedText.substring(0, 100)}...'
                      : selectionState.selectedText,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Copy button
                  _buildActionButton(
                    icon: Icons.copy,
                    label: 'Copy',
                    onPressed: () {
                      ref.read(textSelectionProvider.notifier).copyToClipboard();
                      _showSnackBar(context, 'Text copied to clipboard');
                    },
                  ),
                  
                  // Speak button
                  _buildActionButton(
                    icon: ttsState.isPlaying ? Icons.pause : Icons.volume_up,
                    label: ttsState.isPlaying ? 'Pause' : 'Speak',
                    isLoading: ttsState.isLoading,
                    onPressed: () async {
                      final selection = ref.read(textSelectionProvider.notifier).getSelectionForTts();
                      if (selection != null) {
                        if (ttsState.isPlaying) {
                          await ref.read(readerTtsProvider.notifier).pause();
                        } else {
                          await ref.read(readerTtsProvider.notifier).speakSelection(selection);
                        }
                      }
                    },
                  ),
                  
                  // Close button
                  _buildActionButton(
                    icon: Icons.close,
                    label: 'Close',
                    onPressed: () {
                      ref.read(textSelectionProvider.notifier).clearSelection();
                    },
                  ),
                ],
              ),
              
              // TTS error display
              if (ttsState.hasError) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ttsState.error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ref.read(readerTtsProvider.notifier).clearError();
                        },
                        icon: const Icon(Icons.close, color: Colors.red, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: isLoading ? null : onPressed,
            icon: isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  )
                : Icon(icon, color: Colors.orange),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange,
      ),
    );
  }
}