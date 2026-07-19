import 'package:cached_network_image/cached_network_image.dart';
import 'package:continua/features/course_view/Ready%20player.dart';
import 'package:continua/features/home/presentation/cubit/course_player_cubit.dart';
import 'package:continua/features/home/presentation/cubit/course_player_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// القسم بتاع الفيديو — الـ Hero بيلف الصورة الثابتة بس (مش الـ BlocBuilder)
/// عشان يفضل شغال صح وقت انتقالات الـ Hero بين الكروت.
/// بيتغيّر شكله حسب حالة CoursePlayerCubit:
/// Loading -> thumbnail + spinner
/// Ready   -> الفيديو الحقيقي + controls (في ملف ready_player.dart)
/// Error   -> رسالة خطأ + زرار إعادة المحاولة
class VideoPlayerSection extends StatelessWidget {
  final String thumbnailUrl;
  final String courseId;

  const VideoPlayerSection({
    super.key,
    required this.thumbnailUrl,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // الصورة دايماً موجودة كـ خلفية/fallback، وهي بس اللي جوا الـ Hero
        Hero(
          tag: 'course_thumbnail_$courseId',
          child: CachedNetworkImage(
            imageUrl: thumbnailUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.black),
            errorWidget: (context, url, error) =>
                Container(color: Colors.black),
          ),
        ),

        // الـ BlocBuilder بقى sibling في الـ Stack، مش child جوا الـ Hero
        BlocBuilder<CoursePlayerCubit, CoursePlayerState>(
          builder: (context, state) {
            if (state is CoursePlayerReady) {
              return const ReadyPlayer();
            }
            if (state is CoursePlayerError) {
              return _ErrorPlayer(message: state.message);
            }
            // Initial أو Loading
            return const _LoadingPlayer();
          },
        ),
      ],
    );
  }
}

class _LoadingPlayer extends StatelessWidget {
  const _LoadingPlayer();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black.withValues(alpha: 0.35)),
        const Center(child: CircularProgressIndicator(color: Colors.white)),
      ],
    );
  }
}

class _ErrorPlayer extends StatelessWidget {
  final String message;

  const _ErrorPlayer({required this.message});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
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
