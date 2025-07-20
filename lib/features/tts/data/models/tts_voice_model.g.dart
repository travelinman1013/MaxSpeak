// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_voice_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TtsVoiceModelAdapter extends TypeAdapter<TtsVoiceModel> {
  @override
  final int typeId = 5;

  @override
  TtsVoiceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TtsVoiceModel(
      id: fields[0] as String,
      name: fields[1] as String,
      language: fields[2] as String,
      locale: fields[3] as String,
      isLocal: fields[4] as bool,
      isDefault: fields[5] as bool,
      gender: fields[6] as String?,
      quality: fields[7] as int?,
      size: fields[8] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, TtsVoiceModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.language)
      ..writeByte(3)
      ..write(obj.locale)
      ..writeByte(4)
      ..write(obj.isLocal)
      ..writeByte(5)
      ..write(obj.isDefault)
      ..writeByte(6)
      ..write(obj.gender)
      ..writeByte(7)
      ..write(obj.quality)
      ..writeByte(8)
      ..write(obj.size);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TtsVoiceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
