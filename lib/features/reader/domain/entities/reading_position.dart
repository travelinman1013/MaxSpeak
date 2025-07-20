import 'package:equatable/equatable.dart';

class ReadingPosition extends Equatable {
  final String documentId;
  final int currentPage;
  final double scrollOffset;
  final double zoomLevel;
  final DateTime lastUpdated;
  final int? selectedTextStart;
  final int? selectedTextEnd;
  final String? selectedText;

  const ReadingPosition({
    required this.documentId,
    required this.currentPage,
    this.scrollOffset = 0.0,
    this.zoomLevel = 1.0,
    required this.lastUpdated,
    this.selectedTextStart,
    this.selectedTextEnd,
    this.selectedText,
  });

  ReadingPosition copyWith({
    String? documentId,
    int? currentPage,
    double? scrollOffset,
    double? zoomLevel,
    DateTime? lastUpdated,
    int? selectedTextStart,
    int? selectedTextEnd,
    String? selectedText,
  }) {
    return ReadingPosition(
      documentId: documentId ?? this.documentId,
      currentPage: currentPage ?? this.currentPage,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      selectedTextStart: selectedTextStart ?? this.selectedTextStart,
      selectedTextEnd: selectedTextEnd ?? this.selectedTextEnd,
      selectedText: selectedText ?? this.selectedText,
    );
  }

  ReadingPosition clearSelection() {
    return copyWith(
      selectedTextStart: null,
      selectedTextEnd: null,
      selectedText: null,
    );
  }

  bool get hasSelection => 
    selectedTextStart != null && 
    selectedTextEnd != null && 
    selectedText != null &&
    selectedText!.isNotEmpty;

  double get progress {
    // Simple progress calculation based on current page
    // This can be enhanced with more sophisticated tracking
    return currentPage.toDouble();
  }

  @override
  List<Object?> get props => [
    documentId,
    currentPage,
    scrollOffset,
    zoomLevel,
    lastUpdated,
    selectedTextStart,
    selectedTextEnd,
    selectedText,
  ];
}