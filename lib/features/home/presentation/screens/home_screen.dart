import 'package:continua/core/const/app_color.dart';
import 'package:continua/core/di/injection_container.dart';
import 'package:continua/features/course_view/course_detail_screen.dart';
import 'package:continua/features/home/domain/entities/course_progress_entity.dart';
import 'package:continua/features/home/presentation/cubit/course_list_cubit.dart';
import 'package:continua/features/home/presentation/cubit/course_list_state.dart';
import 'package:continua/features/home/presentation/screens/widgets/cources_header.dart';
import 'package:continua/features/home/presentation/screens/widgets/course_list_error_view.dart';
import 'package:continua/features/home/presentation/screens/widgets/courses_card.dart';
import 'package:continua/features/home/presentation/screens/widgets/home_header.dart';
import 'package:continua/features/home/presentation/screens/widgets/search_textfield.dart';
import 'package:continua/features/home/presentation/screens/widgets/welcme_sction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CourseListCubit>()..loadCourses(),
      child: const _HomeScreenView(),
    );
  }
}

class _HomeScreenView extends StatelessWidget {
  const _HomeScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolor.backgroundcolor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<CourseListCubit>().loadCourses(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HomeHeader(),
                  const WelcmeSction(),
                  const SearchTextfield(),
                  const CourcesHeader(),
                  const SizedBox(height: 12),
                  BlocBuilder<CourseListCubit, CourseListState>(
                    builder: (context, state) {
                      if (state is CourseListLoading ||
                          state is CourseListInitial) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (state is CourseListError) {
                        return CourseListErrorView(
                          message: state.message,
                          onRetry: () =>
                              context.read<CourseListCubit>().loadCourses(),
                        );
                      }

                      final loadedState = state as CourseListLoaded;
                      final courses = loadedState.courses;
                      final progressMap = loadedState.progressByCourseId;

                      if (courses.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: Text('لا يوجد كورسات حالياً')),
                        );
                      }

                      return Column(
                        children: courses.map((course) {
                          final CourseProgressEntity? progress =
                              progressMap[course.id];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: CoursesCard(
                              course: course,
                              progressPercent: progress?.percent ?? 0,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CourseDetailScreen(course: course),
                                  ),
                                );

                                if (context.mounted) {
                                  context.read<CourseListCubit>().loadCourses();
                                }
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
