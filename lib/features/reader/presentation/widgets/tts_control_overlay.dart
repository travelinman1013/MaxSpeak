import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reader_tts_provider.dart';
import '../providers/text_selection_provider.dart';

class TtsControlOverlay extends ConsumerWidget {
  const TtsControlOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsState = ref.watch(readerTtsProvider);
    final selectionState = ref.watch(textSelectionProvider);

    // Only show if TTS is active or has been used
    if (!ttsState.isInitialized || 
        (ttsState.isStopped && ttsState.currentText == null)) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TTS Status Header
              Row(
                children: [
                  Icon(
                    ttsState.isPlaying ? Icons.volume_up : Icons.volume_off,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ttsState.playbackStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (ttsState.totalWords > 0)
                    Text(
                      '${ttsState.currentWordIndex} / ${ttsState.totalWords}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),

              // Progress bar
              if (ttsState.totalWords > 0) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: ttsState.progress,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ],

              const SizedBox(height: 12),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Previous/Skip backward (placeholder)
                  _buildControlButton(
                    icon: Icons.skip_previous,
                    onPressed: null, // Implement skip backward
                    tooltip: 'Skip Backward',
                  ),

                  // Play/Pause button
                  _buildControlButton(
                    icon: ttsState.isPlaying ? Icons.pause : Icons.play_arrow,
                    onPressed: ttsState.isLoading ? null : () async {
                      if (ttsState.isPlaying) {
                        await ref.read(readerTtsProvider.notifier).pause();
                      } else if (ttsState.isPaused) {
                        await ref.read(readerTtsProvider.notifier).resume();
                      } else {
                        // Start speaking selected text or show hint
                        final selection = selectionState.currentSelection;
                        if (selection != null) {
                          await ref.read(readerTtsProvider.notifier).speakSelection(selection);
                        } else {
                          _showHint(context, 'Select text to start speaking');
                        }
                      }
                    },
                    tooltip: ttsState.isPlaying ? 'Pause' : 'Play',
                    isLoading: ttsState.isLoading,
                  ),

                  // Stop button
                  _buildControlButton(
                    icon: Icons.stop,
                    onPressed: ttsState.isStopped ? null : () async {
                      await ref.read(readerTtsProvider.notifier).stop();
                    },
                    tooltip: 'Stop',
                  ),

                  // Next/Skip forward (placeholder)
                  _buildControlButton(
                    icon: Icons.skip_next,
                    onPressed: null, // Implement skip forward
                    tooltip: 'Skip Forward',
                  ),

                  // Settings button
                  _buildControlButton(
                    icon: Icons.settings,
                    onPressed: () => _showTtsSettings(context, ref),
                    tooltip: 'TTS Settings',
                  ),
                ],
              ),

              // Current text preview
              if (ttsState.currentText != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ttsState.currentText!.length > 80
                        ? '${ttsState.currentText!.substring(0, 80)}...'
                        : ttsState.currentText!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    bool isLoading = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: onPressed != null 
              ? Colors.orange.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                )
              : Icon(
                  icon, 
                  color: onPressed != null ? Colors.orange : Colors.grey,
                  size: 20,
                ),
          padding: const EdgeInsets.all(8),
        ),
      ),
    );
  }

  void _showTtsSettings(BuildContext context, WidgetRef ref) {
    final ttsState = ref.read(readerTtsProvider);

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
              'TTS Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Speech Rate
            Text(
              'Speech Rate: ${ttsState.settings.speechRatePercentage}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Slider(
              value: ttsState.settings.speechRate,
              min: 0.5,
              max: 3.0,
              divisions: 10,
              activeColor: Colors.orange,
              onChanged: (value) {
                final newSettings = ttsState.settings.copyWith(speechRate: value);
                ref.read(readerTtsProvider.notifier).updateSettings(newSettings);
              },
            ),
            
            const SizedBox(height: 16),
            
            // Pitch
            Text(
              'Pitch: ${ttsState.settings.pitchDescription}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Slider(
              value: ttsState.settings.pitch,
              min: 0.5,
              max: 2.0,
              divisions: 6,
              activeColor: Colors.orange,
              onChanged: (value) {
                final newSettings = ttsState.settings.copyWith(pitch: value);
                ref.read(readerTtsProvider.notifier).updateSettings(newSettings);
              },
            ),
            
            const SizedBox(height: 16),
            
            // Volume
            Text(
              'Volume: ${(ttsState.settings.volume * 100).toInt()}%',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Slider(
              value: ttsState.settings.volume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              activeColor: Colors.orange,
              onChanged: (value) {
                final newSettings = ttsState.settings.copyWith(volume: value);
                ref.read(readerTtsProvider.notifier).updateSettings(newSettings);
              },
            ),
            
            const SizedBox(height: 16),
            
            // Feature toggles
            SwitchListTile(
              title: const Text(
                'Highlight Words',
                style: TextStyle(color: Colors.white),
              ),
              value: ttsState.settings.highlightWords,
              activeColor: Colors.orange,
              onChanged: (value) {
                final newSettings = ttsState.settings.copyWith(highlightWords: value);
                ref.read(readerTtsProvider.notifier).updateSettings(newSettings);
              },
            ),
            
            SwitchListTile(
              title: const Text(
                'Auto Scroll',
                style: TextStyle(color: Colors.white),
              ),
              value: ttsState.settings.autoScroll,
              activeColor: Colors.orange,
              onChanged: (value) {
                final newSettings = ttsState.settings.copyWith(autoScroll: value);
                ref.read(readerTtsProvider.notifier).updateSettings(newSettings);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showHint(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
