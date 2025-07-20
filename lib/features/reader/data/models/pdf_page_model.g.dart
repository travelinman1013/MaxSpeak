// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_page_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PdfPageModelAdapter extends TypeAdapter<PdfPageModel> {
  @override
  final int typeId = 3;

  @override
  PdfPageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PdfPageModel(
      pageNumber: fields[0] as int,
      width: fields[1] as double,
      height: fields[2] as double,
      thumbnailPath: fields[3] as String?,
      extractedText: fields[4] as String?,
      isLoaded: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PdfPageModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.pageNumber)
      ..writeByte(1)
      ..write(obj.width)
      ..writeByte(2)
      ..write(obj.height)
      ..writeByte(3)
      ..write(obj.thumbnailPath)
      ..writeByte(4)
      ..write(obj.extractedText)
      ..writeByte(5)
      ..write(obj.isLoaded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdfPageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
