import 'package:continua/core/di/injection_container.dart';
import 'package:continua/features/course_view/Video%20player%20section.dart';
import 'package:continua/features/home/domain/entities/course_entity.dart';
import 'package:continua/features/home/presentation/cubit/course_player_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CourseDetailScreen extends StatelessWidget {
  final CourseEntity course;
  final double progressPercent;

  const CourseDetailScreen({
    super.key,
    required this.course,
    this.progressPercent = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<CoursePlayerCubit>()
            ..initialize(courseId: course.id, videoUrl: course.videoUrl),
      child: _CourseDetailView(course: course),
    );
  }
}

class _CourseDetailView extends StatelessWidget {
  final CourseEntity course;

  const _CourseDetailView({required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: false,
            floating: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            expandedHeight: MediaQuery.of(context).size.width * 9 / 16,
            flexibleSpace: FlexibleSpaceBar(
              background: VideoPlayerSection(
                thumbnailUrl: course.thumbnailUrl,
                courseId: course.id,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  course.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  course.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
