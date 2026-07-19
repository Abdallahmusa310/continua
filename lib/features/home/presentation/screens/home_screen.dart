import 'dart:ui';
import 'package:continua/features/course_view/course_detail_screen.dart';
import 'package:continua/features/home/presentation/cubit/course_list_cubit.dart';
import 'package:continua/features/home/presentation/cubit/course_list_state.dart';
import 'package:continua/features/home/presentation/screens/widgets/course_card.dart';
import 'package:continua/features/home/presentation/screens/widgets/course_list_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CourseListCubit>()..loadCourses(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: RefreshIndicator(
        onRefresh: () => context.read<CourseListCubit>().loadCourses(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.55),
                      border: Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                'Continua',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Color(0xff265ADA),
                  fontSize: 26,
                ),
              ),
              centerTitle: true,
            ),
            BlocBuilder<CourseListCubit, CourseListState>(
              builder: (context, state) {
                if (state is CourseListLoading || state is CourseListInitial) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is CourseListError) {
                  return SliverFillRemaining(
                    child: CourseListErrorView(
                      message: state.message,
                      onRetry: () =>
                          context.read<CourseListCubit>().loadCourses(),
                    ),
                  );
                }

                final loadedState = state as CourseListLoaded;
                final courses = loadedState.courses;
                final progressMap = loadedState.progressByCourseId;

                if (courses.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('لا يوجد كورسات حالياً')),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      final progress = progressMap[course.id];
                      return CourseCard(
                        course: course,
                        progressPercent: progress?.percent ?? 0,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(
                                milliseconds: 400,
                              ),
                              reverseTransitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      CourseDetailScreen(
                                        course: course,
                                        progressPercent: progress?.percent ?? 0,
                                      ),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    final curved = CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    );
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(
                                          0,
                                          0.12,
                                        ), // بتيجي من تحت شوية
                                        end: Offset.zero,
                                      ).animate(curved),
                                      child: ScaleTransition(
                                        scale: Tween<double>(
                                          begin: 0.94,
                                          end: 1.0,
                                        ).animate(curved),
                                        child: FadeTransition(
                                          opacity: curved,
                                          child: child,
                                        ),
                                      ),
                                    );
                                  },
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
