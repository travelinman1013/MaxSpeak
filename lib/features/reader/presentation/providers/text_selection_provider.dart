import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/text_selection.dart' as domain;

class TextSelectionState {
  final domain.TextSelection? currentSelection;
  final bool isSelecting;
  final bool showSelectionMenu;
  final String? error;

  const TextSelectionState({
    this.currentSelection,
    this.isSelecting = false,
    this.showSelectionMenu = false,
    this.error,
  });

  TextSelectionState copyWith({
    domain.TextSelection? currentSelection,
    bool? isSelecting,
    bool? showSelectionMenu,
    String? error,
  }) {
    return TextSelectionState(
      currentSelection: currentSelection ?? this.currentSelection,
      isSelecting: isSelecting ?? this.isSelecting,
      showSelectionMenu: showSelectionMenu ?? this.showSelectionMenu,
      error: error ?? this.error,
    );
  }

  bool get hasSelection => currentSelection != null && currentSelection!.isNotEmpty;
  String get selectedText => currentSelection?.selectedText ?? '';
  int get wordCount => currentSelection?.wordCount ?? 0;
  int get estimatedTtsSeconds => currentSelection?.estimatedTtsSeconds ?? 0;
}

class TextSelectionNotifier extends StateNotifier<TextSelectionState> {
  TextSelectionNotifier() : super(const TextSelectionState());

  void startSelection(String documentId, int pageNumber, double x, double y) {
    if (kDebugMode) {
      print('Starting text selection at ($x, $y) on page $pageNumber');
    }
    
    state = state.copyWith(
      isSelecting: true,
      showSelectionMenu: false,
      error: null,
    );
  }

  void updateSelection({
    required String documentId,
    required int pageNumber,
    required String selectedText,
    required int startOffset,
    required int endOffset,
    required double startX,
    required double startY,
    required double endX,
    required double endY,
  }) {
    if (selectedText.trim().isEmpty) {
      clearSelection();
      return;
    }

    final selection = domain.TextSelection(
      documentId: documentId,
      pageNumber: pageNumber,
      selectedText: selectedText.trim(),
      startOffset: startOffset,
      endOffset: endOffset,
      startX: startX,
      startY: startY,
      endX: endX,
      endY: endY,
      selectionTime: DateTime.now(),
    );

    state = state.copyWith(
      currentSelection: selection,
      isSelecting: true,
      showSelectionMenu: false,
    );

    if (kDebugMode) {
      print('Updated selection: ${selectedText.substring(0, selectedText.length.clamp(0, 50))}...');
    }
  }

  void finishSelection() {
    if (state.hasSelection) {
      state = state.copyWith(
        isSelecting: false,
        showSelectionMenu: true,
      );
      
      if (kDebugMode) {
        print('Finished selection: ${state.selectedText.substring(0, state.selectedText.length.clamp(0, 50))}...');
      }
    } else {
      clearSelection();
    }
  }

  void clearSelection() {
    state = const TextSelectionState();
    
    if (kDebugMode) {
      print('Cleared text selection');
    }
  }

  void hideSelectionMenu() {
    state = state.copyWith(showSelectionMenu: false);
  }

  void showSelectionMenu() {
    if (state.hasSelection) {
      state = state.copyWith(showSelectionMenu: true);
    }
  }

  // Copy selected text to clipboard
  void copyToClipboard() {
    if (state.hasSelection) {
      // Note: In a real app, you'd use Clipboard.setData here
      // For now, we'll just log it
      if (kDebugMode) {
        print('Copied to clipboard: ${state.selectedText}');
      }
    }
  }

  // Get selection for TTS
  domain.TextSelection? getSelectionForTts() {
    return state.hasSelection ? state.currentSelection : null;
  }

  // Select entire page (for TTS)
  void selectEntirePage(String documentId, int pageNumber, String pageText) {
    if (pageText.trim().isEmpty) {
      state = state.copyWith(error: 'No text found on this page');
      return;
    }

    final selection = domain.TextSelection(
      documentId: documentId,
      pageNumber: pageNumber,
      selectedText: pageText.trim(),
      startOffset: 0,
      endOffset: pageText.length,
      startX: 0,
      startY: 0,
      endX: 100, // Placeholder coordinates
      endY: 100,
      selectionTime: DateTime.now(),
    );

    state = state.copyWith(
      currentSelection: selection,
      isSelecting: false,
      showSelectionMenu: true,
      error: null,
    );

    if (kDebugMode) {
      print('Selected entire page: ${pageText.substring(0, pageText.length.clamp(0, 100))}...');
    }
  }
}

final textSelectionProvider = StateNotifierProvider<TextSelectionNotifier, TextSelectionState>((ref) {
  return TextSelectionNotifier();
});