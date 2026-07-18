import 'package:continua/core/error/failures.dart' show Failure;
import 'package:continua/features/home/domain/entities/course_entity.dart';
import 'package:continua/features/home/domain/entities/course_progress_entity.dart';
import 'package:dartz/dartz.dart';

abstract class CourseRepository {
  Future<Either<Failure, List<CourseEntity>>> getCourses();

  Future<Either<Failure, CourseProgressEntity>> getCourseProgress(
    String courseId,
  );

  Future<Either<Failure, void>> saveCourseProgress(
    CourseProgressEntity progress,
  );
}
