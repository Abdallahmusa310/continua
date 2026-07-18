import 'package:equatable/equatable.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/course_progress_entity.dart';

abstract class CourseListState extends Equatable {
  const CourseListState();

  @override
  List<Object?> get props => [];
}

class CourseListInitial extends CourseListState {
  const CourseListInitial();
}

class CourseListLoading extends CourseListState {
  const CourseListLoading();
}

class CourseListLoaded extends CourseListState {
  final List<CourseEntity> courses;
  final Map<String, CourseProgressEntity> progressByCourseId;

  const CourseListLoaded({
    required this.courses,
    required this.progressByCourseId,
  });

  @override
  List<Object?> get props => [courses, progressByCourseId];
}

class CourseListError extends CourseListState {
  final String message;

  const CourseListError(this.message);

  @override
  List<Object?> get props => [message];
}
