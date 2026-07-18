import 'package:continua/features/home/domain/repositories/course_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/course_progress_entity.dart';

class SaveCourseProgressUsecase {
  final CourseRepository repository;

  const SaveCourseProgressUsecase(this.repository);

  Future<Either<Failure, void>> call(CourseProgressEntity progress) {
    return repository.saveCourseProgress(progress);
  }
}
