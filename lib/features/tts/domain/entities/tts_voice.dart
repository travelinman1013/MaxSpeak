import 'package:equatable/equatable.dart';

class TtsVoice extends Equatable {
  final String id;
  final String name;
  final String language;
  final String locale;
  final bool isLocal;
  final bool isDefault;
  final String? gender;
  final int? quality; // 1-5 rating
  final double? size; // Size in MB for downloaded voices

  const TtsVoice({
    required this.id,
    required this.name,
    required this.language,
    required this.locale,
    this.isLocal = true,
    this.isDefault = false,
    this.gender,
    this.quality,
    this.size,
  });

  TtsVoice copyWith({
    String? id,
    String? name,
    String? language,
    String? locale,
    bool? isLocal,
    bool? isDefault,
    String? gender,
    int? quality,
    double? size,
  }) {
    return TtsVoice(
      id: id ?? this.id,
      name: name ?? this.name,
      language: language ?? this.language,
      locale: locale ?? this.locale,
      isLocal: isLocal ?? this.isLocal,
      isDefault: isDefault ?? this.isDefault,
      gender: gender ?? this.gender,
      quality: quality ?? this.quality,
      size: size ?? this.size,
    );
  }

  String get displayName => '$name ($language)';
  bool get isMale => gender?.toLowerCase() == 'male';
  bool get isFemale => gender?.toLowerCase() == 'female';
  
  String get qualityDescription {
    switch (quality) {
      case 5: return 'Excellent';
      case 4: return 'High';
      case 3: return 'Good';
      case 2: return 'Fair';
      case 1: return 'Basic';
      default: return 'Unknown';
    }
  }

  @override
  List<Object?> get props => [
    id,
    name,
    language,
    locale,
    isLocal,
    isDefault,
    gender,
    quality,
    size,
  ];

  @override
  String toString() => 'TtsVoice(id: $id, name: $name, language: $language)';
}