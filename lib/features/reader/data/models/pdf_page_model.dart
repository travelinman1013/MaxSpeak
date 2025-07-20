import 'package:hive/hive.dart';
import '../../domain/entities/pdf_page.dart';

part 'pdf_page_model.g.dart';

@HiveType(typeId: 3)
class PdfPageModel extends PdfPage {
  @HiveField(0)
  @override
  final int pageNumber;
  
  @HiveField(1)
  @override
  final double width;
  
  @HiveField(2)
  @override
  final double height;
  
  @HiveField(3)
  @override
  final String? thumbnailPath;
  
  @HiveField(4)
  @override
  final String? extractedText;
  
  @HiveField(5)
  @override
  final bool isLoaded;

  const PdfPageModel({
    required this.pageNumber,
    required this.width,
    required this.height,
    this.thumbnailPath,
    this.extractedText,
    this.isLoaded = false,
  }) : super(
    pageNumber: pageNumber,
    width: width,
    height: height,
    thumbnailPath: thumbnailPath,
    extractedText: extractedText,
    isLoaded: isLoaded,
  );

  factory PdfPageModel.fromEntity(PdfPage page) {
    return PdfPageModel(
      pageNumber: page.pageNumber,
      width: page.width,
      height: page.height,
      thumbnailPath: page.thumbnailPath,
      extractedText: page.extractedText,
      isLoaded: page.isLoaded,
    );
  }

  @override
  PdfPageModel copyWith({
    int? pageNumber,
    double? width,
    double? height,
    String? thumbnailPath,
    String? extractedText,
    bool? isLoaded,
  }) {
    return PdfPageModel(
      pageNumber: pageNumber ?? this.pageNumber,
      width: width ?? this.width,
      height: height ?? this.height,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      extractedText: extractedText ?? this.extractedText,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}
