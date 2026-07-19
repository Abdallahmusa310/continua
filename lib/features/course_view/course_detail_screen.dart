import 'package:continua/core/di/injection_container.dart';
import 'package:continua/features/home/domain/entities/course_entity.dart';
import 'package:continua/features/home/presentation/cubit/course_player_cubit.dart';
import 'package:continua/features/home/presentation/cubit/course_player_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

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
              background: _VideoPlayerSection(
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

/// القسم بتاع الفيديو — بيتغيّر شكله حسب حالة CoursePlayerCubit:
/// Loading -> thumbnail + spinner
/// Ready   -> الفيديو الحقيقي + controls
/// Error   -> رسالة خطأ + زرار إعادة المحاولة
/// ملفوف بـ Hero عشان الانتقال الناعم من الكارد يفضل شغال
class _VideoPlayerSection extends StatelessWidget {
  final String thumbnailUrl;
  final String courseId;

  const _VideoPlayerSection({
    required this.thumbnailUrl,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'course_thumbnail_$courseId',
      child: BlocBuilder<CoursePlayerCubit, CoursePlayerState>(
        builder: (context, state) {
          if (state is CoursePlayerReady) {
            return _ReadyPlayer(courseId: courseId);
          }
          if (state is CoursePlayerError) {
            return _ErrorPlayer(
              thumbnailUrl: thumbnailUrl,
              message: state.message,
            );
          }
          // Initial أو Loading بيوريا نفس الشكل: الـ thumbnail + spinner
          return _LoadingPlayer(thumbnailUrl: thumbnailUrl);
        },
      ),
    );
  }
}

class _LoadingPlayer extends StatelessWidget {
  final String thumbnailUrl;

  const _LoadingPlayer({required this.thumbnailUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: thumbnailUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.black),
          errorWidget: (context, url, error) => Container(color: Colors.black),
        ),
        Container(color: Colors.black.withValues(alpha: 0.35)),
        const Center(child: CircularProgressIndicator(color: Colors.white)),
      ],
    );
  }
}

class _ErrorPlayer extends StatelessWidget {
  final String thumbnailUrl;
  final String message;

  const _ErrorPlayer({required this.thumbnailUrl, required this.message});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: thumbnailUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.black),
          errorWidget: (context, url, error) => Container(color: Colors.black),
        ),
        Container(color: Colors.black.withValues(alpha: 0.55)),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 40),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                onPressed: () => context.read<CoursePlayerCubit>().retry(),
                child: const Text('حاول تاني'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReadyPlayer extends StatefulWidget {
  final String courseId;

  const _ReadyPlayer({required this.courseId});

  @override
  State<_ReadyPlayer> createState() => _ReadyPlayerState();
}

class _ReadyPlayerState extends State<_ReadyPlayer> {
  static const _speedOptions = [0.5, 1.0, 1.25, 1.5, 2.0];
  double _selectedSpeed = 1.0;

  String get _speedLabel => _selectedSpeed == _selectedSpeed.roundToDouble()
      ? '${_selectedSpeed.toInt()}x'
      : '${_selectedSpeed}x';

  void _openSpeedMenu() async {
    final cubit = context.read<CoursePlayerCubit>();

    final selected = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _speedOptions.map((speed) {
            final label = speed == speed.roundToDouble()
                ? '${speed.toInt()}x'
                : '${speed}x';
            return ListTile(
              title: Text(label),
              trailing: speed == _selectedSpeed
                  ? const Icon(Icons.check, color: Color(0xff265ADA))
                  : null,
              onTap: () => Navigator.pop(context, speed),
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null) {
      setState(() => _selectedSpeed = selected);
      await cubit.setSpeed(selected);
    }
  }

  void _openFullscreen(VideoPlayerController controller) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullscreenVideoPlayer(controller: controller),
        fullscreenDialog: true,
      ),
    );
    // TODO: نضيف SystemChrome.setPreferredOrientations للتدوير الفعلي للشاشة
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<CoursePlayerCubit>().controller;

    if (controller == null || !controller.value.isInitialized) {
      // حالة دفاعية، مفروض معدّيهاش لو الـ state Ready
      return Container(color: Colors.black);
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),

            // تعتيم خفيف + زرار Play/Pause في النص
            GestureDetector(
              onTap: () => context.read<CoursePlayerCubit>().togglePlayPause(),
              child: Container(
                color: Colors.black.withValues(
                  alpha: value.isPlaying ? 0 : 0.25,
                ),
                alignment: Alignment.center,
                child: AnimatedOpacity(
                  opacity: value.isPlaying ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.play_circle_fill,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // شريط الـ controls تحت
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                color: Colors.black.withValues(alpha: 0.4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          _formatDuration(value.position),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: VideoProgressIndicator(
                            controller,
                            allowScrubbing: true,
                            padding: EdgeInsets.zero,
                            colors: const VideoProgressColors(
                              playedColor: Colors.white,
                              bufferedColor: Colors.white24,
                              backgroundColor: Colors.white10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDuration(value.duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _openSpeedMenu,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Text(
                            _speedLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _openFullscreen(controller),
                          icon: const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                            size: 22,
                          ),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// شاشة التكبير الكامل — بتستخدم نفس الـ controller (مفيش تحميل مزدوج للفيديو)
class _FullscreenVideoPlayer extends StatelessWidget {
  final VideoPlayerController controller;

  const _FullscreenVideoPlayer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
