// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_position_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingPositionModelAdapter extends TypeAdapter<ReadingPositionModel> {
  @override
  final int typeId = 4;

  @override
  ReadingPositionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingPositionModel(
      documentId: fields[0] as String,
      currentPage: fields[1] as int,
      scrollOffset: fields[2] as double,
      zoomLevel: fields[3] as double,
      lastUpdated: fields[4] as DateTime,
      selectedTextStart: fields[5] as int?,
      selectedTextEnd: fields[6] as int?,
      selectedText: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingPositionModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.documentId)
      ..writeByte(1)
      ..write(obj.currentPage)
      ..writeByte(2)
      ..write(obj.scrollOffset)
      ..writeByte(3)
      ..write(obj.zoomLevel)
      ..writeByte(4)
      ..write(obj.lastUpdated)
      ..writeByte(5)
      ..write(obj.selectedTextStart)
      ..writeByte(6)
      ..write(obj.selectedTextEnd)
      ..writeByte(7)
      ..write(obj.selectedText);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingPositionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
