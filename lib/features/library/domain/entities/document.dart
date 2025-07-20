import 'package:equatable/equatable.dart';

class Document extends Equatable {
  final String id;
  final String title;
  final String filePath;
  final String originalFileName;
  final int totalPages;
  final int fileSizeBytes;
  final DateTime dateAdded;
  final DateTime lastOpened;
  final double readingProgress; // 0.0 to 1.0
  final int currentPage;
  final String? coverImagePath;
  final bool isEncrypted;
  final Map<String, dynamic>? metadata;

  const Document({
    required this.id,
    required this.title,
    required this.filePath,
    required this.originalFileName,
    required this.totalPages,
    required this.fileSizeBytes,
    required this.dateAdded,
    required this.lastOpened,
    this.readingProgress = 0.0,
    this.currentPage = 1,
    this.coverImagePath,
    this.isEncrypted = true,
    this.metadata,
  });

  // Calculate reading status
  bool get isCompleted => readingProgress >= 1.0;
  bool get isStarted => readingProgress > 0.0;
  String get readingStatus {
    if (isCompleted) return 'Completed';
    if (isStarted) return '${(readingProgress * 100).round()}% read';
    return 'Not started';
  }

  // File size in MB
  double get fileSizeMB => fileSizeBytes / (1024 * 1024);

  // Create a copy with updated fields
  Document copyWith({
    String? id,
    String? title,
    String? filePath,
    String? originalFileName,
    int? totalPages,
    int? fileSizeBytes,
    DateTime? dateAdded,
    DateTime? lastOpened,
    double? readingProgress,
    int? currentPage,
    String? coverImagePath,
    bool? isEncrypted,
    Map<String, dynamic>? metadata,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      originalFileName: originalFileName ?? this.originalFileName,
      totalPages: totalPages ?? this.totalPages,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      dateAdded: dateAdded ?? this.dateAdded,
      lastOpened: lastOpened ?? this.lastOpened,
      readingProgress: readingProgress ?? this.readingProgress,
      currentPage: currentPage ?? this.currentPage,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        filePath,
        originalFileName,
        totalPages,
        fileSizeBytes,
        dateAdded,
        lastOpened,
        readingProgress,
        currentPage,
        coverImagePath,
        isEncrypted,
        metadata,
      ];
}