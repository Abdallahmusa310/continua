import 'package:continua/features/home/domain/repositories/course_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/course_progress_entity.dart';

class GetCourseProgressUsecase {
  final CourseRepository repository;

  const GetCourseProgressUsecase(this.repository);

  Future<Either<Failure, CourseProgressEntity>> call(String courseId) {
    return repository.getCourseProgress(courseId);
  }
}
