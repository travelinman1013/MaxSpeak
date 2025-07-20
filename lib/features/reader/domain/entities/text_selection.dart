import 'package:equatable/equatable.dart';

class TextSelection extends Equatable {
  final String documentId;
  final int pageNumber;
  final String selectedText;
  final int startOffset;
  final int endOffset;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final DateTime selectionTime;

  const TextSelection({
    required this.documentId,
    required this.pageNumber,
    required this.selectedText,
    required this.startOffset,
    required this.endOffset,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.selectionTime,
  });

  TextSelection copyWith({
    String? documentId,
    int? pageNumber,
    String? selectedText,
    int? startOffset,
    int? endOffset,
    double? startX,
    double? startY,
    double? endX,
    double? endY,
    DateTime? selectionTime,
  }) {
    return TextSelection(
      documentId: documentId ?? this.documentId,
      pageNumber: pageNumber ?? this.pageNumber,
      selectedText: selectedText ?? this.selectedText,
      startOffset: startOffset ?? this.startOffset,
      endOffset: endOffset ?? this.endOffset,
      startX: startX ?? this.startX,
      startY: startY ?? this.startY,
      endX: endX ?? this.endX,
      endY: endY ?? this.endY,
      selectionTime: selectionTime ?? this.selectionTime,
    );
  }

  bool get isEmpty => selectedText.isEmpty;
  bool get isNotEmpty => selectedText.isNotEmpty;
  
  int get length => selectedText.length;
  
  // Get word count for TTS estimation
  int get wordCount => selectedText.trim().split(RegExp(r'\s+')).length;
  
  // Estimate reading time in seconds (assuming 200 WPM for TTS)
  int get estimatedTtsSeconds => ((wordCount / 200) * 60).round();

  @override
  List<Object?> get props => [
    documentId,
    pageNumber,
    selectedText,
    startOffset,
    endOffset,
    startX,
    startY,
    endX,
    endY,
    selectionTime,
  ];

  @override
  String toString() {
    return 'TextSelection(page: $pageNumber, text: "${selectedText.length > 50 ? '${selectedText.substring(0, 50)}...' : selectedText}")';
  }
}