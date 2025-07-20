import 'package:hive/hive.dart';
import '../../domain/entities/reading_position.dart';

part 'reading_position_model.g.dart';

@HiveType(typeId: 4)
class ReadingPositionModel extends ReadingPosition {
  @HiveField(0)
  @override
  final String documentId;
  
  @HiveField(1)
  @override
  final int currentPage;
  
  @HiveField(2)
  @override
  final double scrollOffset;
  
  @HiveField(3)
  @override
  final double zoomLevel;
  
  @HiveField(4)
  @override
  final DateTime lastUpdated;
  
  @HiveField(5)
  @override
  final int? selectedTextStart;
  
  @HiveField(6)
  @override
  final int? selectedTextEnd;
  
  @HiveField(7)
  @override
  final String? selectedText;

  const ReadingPositionModel({
    required this.documentId,
    required this.currentPage,
    this.scrollOffset = 0.0,
    this.zoomLevel = 1.0,
    required this.lastUpdated,
    this.selectedTextStart,
    this.selectedTextEnd,
    this.selectedText,
  }) : super(
    documentId: documentId,
    currentPage: currentPage,
    scrollOffset: scrollOffset,
    zoomLevel: zoomLevel,
    lastUpdated: lastUpdated,
    selectedTextStart: selectedTextStart,
    selectedTextEnd: selectedTextEnd,
    selectedText: selectedText,
  );

  factory ReadingPositionModel.fromEntity(ReadingPosition position) {
    return ReadingPositionModel(
      documentId: position.documentId,
      currentPage: position.currentPage,
      scrollOffset: position.scrollOffset,
      zoomLevel: position.zoomLevel,
      lastUpdated: position.lastUpdated,
      selectedTextStart: position.selectedTextStart,
      selectedTextEnd: position.selectedTextEnd,
      selectedText: position.selectedText,
    );
  }

  @override
  ReadingPositionModel copyWith({
    String? documentId,
    int? currentPage,
    double? scrollOffset,
    double? zoomLevel,
    DateTime? lastUpdated,
    int? selectedTextStart,
    int? selectedTextEnd,
    String? selectedText,
  }) {
    return ReadingPositionModel(
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
}
