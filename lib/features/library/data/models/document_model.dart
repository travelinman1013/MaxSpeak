import 'package:hive/hive.dart';
import '../../domain/entities/document.dart';

part 'document_model.g.dart';

@HiveType(typeId: 0)
class DocumentModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String filePath;

  @HiveField(3)
  late String originalFileName;

  @HiveField(4)
  late int totalPages;

  @HiveField(5)
  late int fileSizeBytes;

  @HiveField(6)
  late DateTime dateAdded;

  @HiveField(7)
  late DateTime lastOpened;

  @HiveField(8)
  late double readingProgress;

  @HiveField(9)
  late int currentPage;

  @HiveField(10)
  String? coverImagePath;

  @HiveField(11)
  late bool isEncrypted;

  @HiveField(12)
  Map<String, dynamic>? metadata;

  DocumentModel({
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

  // Convert from entity
  factory DocumentModel.fromEntity(Document document) {
    return DocumentModel(
      id: document.id,
      title: document.title,
      filePath: document.filePath,
      originalFileName: document.originalFileName,
      totalPages: document.totalPages,
      fileSizeBytes: document.fileSizeBytes,
      dateAdded: document.dateAdded,
      lastOpened: document.lastOpened,
      readingProgress: document.readingProgress,
      currentPage: document.currentPage,
      coverImagePath: document.coverImagePath,
      isEncrypted: document.isEncrypted,
      metadata: document.metadata,
    );
  }

  // Convert to entity
  Document toEntity() {
    return Document(
      id: id,
      title: title,
      filePath: filePath,
      originalFileName: originalFileName,
      totalPages: totalPages,
      fileSizeBytes: fileSizeBytes,
      dateAdded: dateAdded,
      lastOpened: lastOpened,
      readingProgress: readingProgress,
      currentPage: currentPage,
      coverImagePath: coverImagePath,
      isEncrypted: isEncrypted,
      metadata: metadata,
    );
  }

  // Convert from JSON (for potential cloud sync)
  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      title: json['title'],
      filePath: json['filePath'],
      originalFileName: json['originalFileName'],
      totalPages: json['totalPages'],
      fileSizeBytes: json['fileSizeBytes'],
      dateAdded: DateTime.parse(json['dateAdded']),
      lastOpened: DateTime.parse(json['lastOpened']),
      readingProgress: json['readingProgress']?.toDouble() ?? 0.0,
      currentPage: json['currentPage'] ?? 1,
      coverImagePath: json['coverImagePath'],
      isEncrypted: json['isEncrypted'] ?? true,
      metadata: json['metadata'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'originalFileName': originalFileName,
      'totalPages': totalPages,
      'fileSizeBytes': fileSizeBytes,
      'dateAdded': dateAdded.toIso8601String(),
      'lastOpened': lastOpened.toIso8601String(),
      'readingProgress': readingProgress,
      'currentPage': currentPage,
      'coverImagePath': coverImagePath,
      'isEncrypted': isEncrypted,
      'metadata': metadata,
    };
  }
}