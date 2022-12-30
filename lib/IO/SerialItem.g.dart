// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SerialItem.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SerialItemAdapter extends TypeAdapter<SerialItem> {
  @override
  final int typeId = 1;

  @override
  SerialItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SerialItem()
      ..identifier = fields[0] as String
      ..target = fields[1] as String
      ..translation = fields[2] as String
      ..level = fields[3] as int
      ..lastUse = fields[4] as DateTime
      ..phonetic = fields[5] as String;
  }

  @override
  void write(BinaryWriter writer, SerialItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.identifier)
      ..writeByte(1)
      ..write(obj.target)
      ..writeByte(2)
      ..write(obj.translation)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(4)
      ..write(obj.lastUse)
      ..writeByte(5)
      ..write(obj.phonetic);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SerialItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
