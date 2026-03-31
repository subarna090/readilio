// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StorySessionAdapter extends TypeAdapter<StorySession> {
  @override
  final int typeId = 0;

  @override
  StorySession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StorySession(
      id: fields[0] as String,
      title: fields[1] as String,
      pages: (fields[2] as List).cast<StoryPage>(),
      createdAt: fields[3] as DateTime,
      lastOpenedAt: fields[4] as DateTime,
      durationSeconds: fields[5] as int,
      isPremium: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, StorySession obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.pages)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.lastOpenedAt)
      ..writeByte(5)
      ..write(obj.durationSeconds)
      ..writeByte(6)
      ..write(obj.isPremium);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorySessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StoryPageAdapter extends TypeAdapter<StoryPage> {
  @override
  final int typeId = 1;

  @override
  StoryPage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoryPage(
      pageNumber: fields[0] as int,
      imagePath: fields[1] as String,
      rawText: fields[2] as String,
      words: (fields[3] as List).cast<String>(),
      avgConfidence: fields[4] as double,
      isEdited: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, StoryPage obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.pageNumber)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.rawText)
      ..writeByte(3)
      ..write(obj.words)
      ..writeByte(4)
      ..write(obj.avgConfidence)
      ..writeByte(5)
      ..write(obj.isEdited);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryPageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
