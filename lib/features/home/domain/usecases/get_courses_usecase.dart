import 'package:continua/features/home/domain/repositories/course_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/course_entity.dart';

class GetCoursesUsecase {
  final CourseRepository repository;

  const GetCoursesUsecase(this.repository);

  Future<Either<Failure, List<CourseEntity>>> call() {
    return repository.getCourses();
  }
}
