import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/course_progress_entity.dart';
import '../../domain/usecases/get_course_progress_usecase.dart';
import '../../domain/usecases/get_courses_usecase.dart';
import 'course_list_state.dart';

class CourseListCubit extends Cubit<CourseListState> {
  final GetCoursesUsecase getCoursesUsecase;
  final GetCourseProgressUsecase getCourseProgressUsecase;

  CourseListCubit({
    required this.getCoursesUsecase,
    required this.getCourseProgressUsecase,
  }) : super(const CourseListInitial());

  Future<void> loadCourses() async {
    emit(const CourseListLoading());

    final coursesResult = await getCoursesUsecase();

    await coursesResult.fold(
      (failure) async => emit(CourseListError(failure.message)),
      (courses) async {
        // بنقرا الـ progress بتاع كل كورس على التوازي عشان السرعة
        final progressMap = <String, CourseProgressEntity>{};

        await Future.wait(
          courses.map((course) async {
            final progressResult = await getCourseProgressUsecase(course.id);
            progressResult.fold((failure) {
              // لو فشلت قراءة progress كورس معين، نسيبه فاضي بدل ما نوقف كل الشاشة
              progressMap[course.id] = CourseProgressEntity.empty(course.id);
            }, (progress) => progressMap[course.id] = progress);
          }),
        );

        emit(
          CourseListLoaded(courses: courses, progressByCourseId: progressMap),
        );
      },
    );
  }
}
