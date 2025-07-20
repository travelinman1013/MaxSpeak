import 'package:hive/hive.dart';
import '../../domain/entities/tts_voice.dart';

part 'tts_voice_model.g.dart';

@HiveType(typeId: 5)
class TtsVoiceModel extends TtsVoice {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String language;
  
  @HiveField(3)
  final String locale;
  
  @HiveField(4)
  final bool isLocal;
  
  @HiveField(5)
  final bool isDefault;
  
  @HiveField(6)
  final String? gender;
  
  @HiveField(7)
  final int? quality;
  
  @HiveField(8)
  final double? size;

  const TtsVoiceModel({
    required this.id,
    required this.name,
    required this.language,
    required this.locale,
    this.isLocal = true,
    this.isDefault = false,
    this.gender,
    this.quality,
    this.size,
  }) : super(
    id: id,
    name: name,
    language: language,
    locale: locale,
    isLocal: isLocal,
    isDefault: isDefault,
    gender: gender,
    quality: quality,
    size: size,
  );

  factory TtsVoiceModel.fromEntity(TtsVoice voice) {
    return TtsVoiceModel(
      id: voice.id,
      name: voice.name,
      language: voice.language,
      locale: voice.locale,
      isLocal: voice.isLocal,
      isDefault: voice.isDefault,
      gender: voice.gender,
      quality: voice.quality,
      size: voice.size,
    );
  }

  factory TtsVoiceModel.fromJson(Map<String, dynamic> json) {
    return TtsVoiceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      language: json['language'] as String,
      locale: json['locale'] as String,
      isLocal: json['isLocal'] as bool? ?? true,
      isDefault: json['isDefault'] as bool? ?? false,
      gender: json['gender'] as String?,
      quality: json['quality'] as int?,
      size: json['size'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'language': language,
      'locale': locale,
      'isLocal': isLocal,
      'isDefault': isDefault,
      'gender': gender,
      'quality': quality,
      'size': size,
    };
  }

  TtsVoiceModel copyWith({
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
    return TtsVoiceModel(
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
}