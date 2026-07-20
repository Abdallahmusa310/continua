import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/course_progress_entity.dart';
import '../../domain/usecases/get_course_progress_usecase.dart';
import '../../domain/usecases/get_courses_usecase.dart';
import 'course_list_state.dart';

class CourseListCubit extends Cubit<CourseListState> {
  final GetCoursesUsecase getCoursesUsecase;
  final GetCourseProgressUsecase getCourseProgressUsecase;
  List<CourseEntity> _allCourses = [];
  Map<String, CourseProgressEntity> _progressMap = {};

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
        final progressMap = <String, CourseProgressEntity>{};

        await Future.wait(
          courses.map((course) async {
            final progressResult = await getCourseProgressUsecase(course.id);
            progressResult.fold((failure) {
              progressMap[course.id] = CourseProgressEntity.empty(course.id);
            }, (progress) => progressMap[course.id] = progress);
          }),
        );

        _allCourses = courses;
        _progressMap = progressMap;

        emit(
          CourseListLoaded(courses: courses, progressByCourseId: progressMap),
        );
      },
    );
  }

  void searchCourses(String query) {
    if (_allCourses.isEmpty) return;
    final trimmedQuery = query.trim().toLowerCase();
    final filtered = trimmedQuery.isEmpty
        ? _allCourses
        : _allCourses
              .where(
                (course) => course.title.toLowerCase().contains(trimmedQuery),
              )
              .toList();

    emit(CourseListLoaded(courses: filtered, progressByCourseId: _progressMap));
  }
}
