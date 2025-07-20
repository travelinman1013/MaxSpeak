import 'package:equatable/equatable.dart';

class PdfPage extends Equatable {
  final int pageNumber;
  final double width;
  final double height;
  final String? thumbnailPath;
  final String? extractedText;
  final bool isLoaded;

  const PdfPage({
    required this.pageNumber,
    required this.width,
    required this.height,
    this.thumbnailPath,
    this.extractedText,
    this.isLoaded = false,
  });

  PdfPage copyWith({
    int? pageNumber,
    double? width,
    double? height,
    String? thumbnailPath,
    String? extractedText,
    bool? isLoaded,
  }) {
    return PdfPage(
      pageNumber: pageNumber ?? this.pageNumber,
      width: width ?? this.width,
      height: height ?? this.height,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      extractedText: extractedText ?? this.extractedText,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  double get aspectRatio => height > 0 ? width / height : 1.0;

  @override
  List<Object?> get props => [
    pageNumber,
    width,
    height,
    thumbnailPath,
    extractedText,
    isLoaded,
  ];
}