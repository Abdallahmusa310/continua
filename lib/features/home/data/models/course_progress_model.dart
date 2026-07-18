import 'package:hive/hive.dart';
import '../../domain/entities/course_progress_entity.dart';

part 'course_progress_model.g.dart';

@HiveType(typeId: 0)
class CourseProgressModel extends CourseProgressEntity {
  @HiveField(0)
  final String hiveCourseId;

  @HiveField(1)
  final int hivePositionSeconds;

  @HiveField(2)
  final double hivePercent;

  @HiveField(3)
  final DateTime hiveUpdatedAt;

  const CourseProgressModel({
    required this.hiveCourseId,
    required this.hivePositionSeconds,
    required this.hivePercent,
    required this.hiveUpdatedAt,
  }) : super(
         courseId: hiveCourseId,
         positionSeconds: hivePositionSeconds,
         percent: hivePercent,
         updatedAt: hiveUpdatedAt,
       );

  factory CourseProgressModel.fromEntity(CourseProgressEntity entity) {
    return CourseProgressModel(
      hiveCourseId: entity.courseId,
      hivePositionSeconds: entity.positionSeconds,
      hivePercent: entity.percent,
      hiveUpdatedAt: entity.updatedAt,
    );
  }
}
