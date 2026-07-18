import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/course_progress_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_local_datasource.dart';
import '../datasources/progress_local_datasource.dart';
import '../models/course_progress_model.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseLocalDataSource courseLocalDataSource;
  final ProgressLocalDataSource progressLocalDataSource;

  const CourseRepositoryImpl({
    required this.courseLocalDataSource,
    required this.progressLocalDataSource,
  });

  @override
  Future<Either<Failure, List<CourseEntity>>> getCourses() async {
    try {
      final courses = await courseLocalDataSource.getCourses();
      return Right(courses);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, CourseProgressEntity>> getCourseProgress(
    String courseId,
  ) async {
    try {
      final model = await progressLocalDataSource.getProgress(courseId);
      return Right(model ?? CourseProgressEntity.empty(courseId));
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveCourseProgress(
    CourseProgressEntity progress,
  ) async {
    try {
      final model = CourseProgressModel.fromEntity(progress);
      await progressLocalDataSource.saveProgress(model);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }
}
