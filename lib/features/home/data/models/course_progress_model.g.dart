// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_progress_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseProgressModelAdapter extends TypeAdapter<CourseProgressModel> {
  @override
  final int typeId = 0;

  @override
  CourseProgressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CourseProgressModel(
      hiveCourseId: fields[0] as String,
      hivePositionSeconds: fields[1] as int,
      hivePercent: fields[2] as double,
      hiveUpdatedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CourseProgressModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.hiveCourseId)
      ..writeByte(1)
      ..write(obj.hivePositionSeconds)
      ..writeByte(2)
      ..write(obj.hivePercent)
      ..writeByte(3)
      ..write(obj.hiveUpdatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseProgressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
