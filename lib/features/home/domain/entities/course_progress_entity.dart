import 'package:equatable/equatable.dart';

class CourseProgressEntity extends Equatable {
  final String courseId;
  final int positionSeconds;
  final double percent; // 0.0 -> 100.0
  final DateTime updatedAt;

  const CourseProgressEntity({
    required this.courseId,
    required this.positionSeconds,
    required this.percent,
    required this.updatedAt,
  });

  bool get isCompleted => percent >= 95.0;

  static CourseProgressEntity empty(String courseId) => CourseProgressEntity(
    courseId: courseId,
    positionSeconds: 0,
    percent: 0.0,
    updatedAt: DateTime.now(),
  );

  @override
  List<Object?> get props => [courseId, positionSeconds, percent, updatedAt];
}
