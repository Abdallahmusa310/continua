import 'package:continua/features/home/data/datasources/course_local_datasource.dart';
import 'package:continua/features/home/data/datasources/progress_local_datasource.dart';
import 'package:continua/features/home/data/models/course_progress_model.dart';
import 'package:continua/features/home/data/repositories/course_repository_impl.dart';
import 'package:continua/features/home/domain/repositories/course_repository.dart';
import 'package:continua/features/home/domain/usecases/get_course_progress_usecase.dart';
import 'package:continua/features/home/domain/usecases/get_courses_usecase.dart';
import 'package:continua/features/home/domain/usecases/save_course_progress_usecase.dart';
import 'package:continua/features/home/presentation/cubit/course_list_cubit.dart';
import 'package:continua/features/home/presentation/cubit/course_player_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // ---------------- External ----------------
  // الـ box لازم يكون اتفتح بالفعل في السبلاش قبل ما ننده init() دي
  final progressBox = Hive.box<CourseProgressModel>('course_progress_box');
  getIt.registerLazySingleton<Box<CourseProgressModel>>(() => progressBox);

  // ---------------- Data sources ----------------
  getIt.registerLazySingleton<CourseLocalDataSource>(
    () => CourseLocalDataSourceImpl(),
  );

  getIt.registerLazySingleton<ProgressLocalDataSource>(
    () => ProgressLocalDataSourceImpl(getIt<Box<CourseProgressModel>>()),
  );

  // ---------------- Repository ----------------
  getIt.registerLazySingleton<CourseRepository>(
    () => CourseRepositoryImpl(
      courseLocalDataSource: getIt<CourseLocalDataSource>(),
      progressLocalDataSource: getIt<ProgressLocalDataSource>(),
    ),
  );

  // ---------------- Usecases ----------------
  getIt.registerLazySingleton(
    () => GetCoursesUsecase(getIt<CourseRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetCourseProgressUsecase(getIt<CourseRepository>()),
  );
  getIt.registerLazySingleton(
    () => SaveCourseProgressUsecase(getIt<CourseRepository>()),
  );

  // ---------------- Cubits ----------------
  // registerFactory عشان كل مرة تتفتح فيها الشاشة ياخد instance جديدة نضيفة
  getIt.registerFactory(
    () => CourseListCubit(
      getCoursesUsecase: getIt<GetCoursesUsecase>(),
      getCourseProgressUsecase: getIt<GetCourseProgressUsecase>(),
    ),
  );
  getIt.registerFactory(
    () => CoursePlayerCubit(
      getCourseProgressUsecase: getIt<GetCourseProgressUsecase>(),
      saveCourseProgressUsecase: getIt<SaveCourseProgressUsecase>(),
    ),
  );
}
