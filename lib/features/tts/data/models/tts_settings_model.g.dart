// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TtsSettingsModelAdapter extends TypeAdapter<TtsSettingsModel> {
  @override
  final int typeId = 6;

  @override
  TtsSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TtsSettingsModel(
      selectedVoice: fields[0] as TtsVoiceModel?,
      speechRate: fields[1] as double,
      pitch: fields[2] as double,
      volume: fields[3] as double,
      autoScroll: fields[4] as bool,
      highlightWords: fields[5] as bool,
      pauseOnPhoneCalls: fields[6] as bool,
      enableBackgroundPlayback: fields[7] as bool,
      skipSeconds: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TtsSettingsModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.selectedVoice)
      ..writeByte(1)
      ..write(obj.speechRate)
      ..writeByte(2)
      ..write(obj.pitch)
      ..writeByte(3)
      ..write(obj.volume)
      ..writeByte(4)
      ..write(obj.autoScroll)
      ..writeByte(5)
      ..write(obj.highlightWords)
      ..writeByte(6)
      ..write(obj.pauseOnPhoneCalls)
      ..writeByte(7)
      ..write(obj.enableBackgroundPlayback)
      ..writeByte(8)
      ..write(obj.skipSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TtsSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TtsPlaybackInfoModelAdapter extends TypeAdapter<TtsPlaybackInfoModel> {
  @override
  final int typeId = 7;

  @override
  TtsPlaybackInfoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TtsPlaybackInfoModel(
      state: fields[0] as TtsPlaybackState,
      currentText: fields[1] as String?,
      currentWordIndex: fields[2] as int,
      totalWords: fields[3] as int,
      currentPosition: fields[4] as Duration,
      totalDuration: fields[5] as Duration,
      error: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TtsPlaybackInfoModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.state)
      ..writeByte(1)
      ..write(obj.currentText)
      ..writeByte(2)
      ..write(obj.currentWordIndex)
      ..writeByte(3)
      ..write(obj.totalWords)
      ..writeByte(4)
      ..write(obj.currentPosition)
      ..writeByte(5)
      ..write(obj.totalDuration)
      ..writeByte(6)
      ..write(obj.error);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TtsPlaybackInfoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
