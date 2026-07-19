import 'package:continua/features/home/presentation/cubit/course_player_cubit.dart';
import 'package:continua/features/home/presentation/cubit/course_player_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

class ReadyPlayer extends StatelessWidget {
  const ReadyPlayer({super.key});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CoursePlayerCubit>();
    final controller = cubit.controller;

    if (controller == null || !controller.value.isInitialized) {
      return Container(color: Colors.black);
    }

    return BlocBuilder<CoursePlayerCubit, CoursePlayerState>(
      builder: (context, state) {
        if (state is! CoursePlayerReady) {
          return Container(color: Colors.black);
        }

        final maxMs = (controller.value.duration.inMilliseconds > 0)
            ? controller.value.duration.inMilliseconds.toDouble()
            : (state.duration.inMilliseconds > 0
                  ? state.duration.inMilliseconds.toDouble()
                  : 1.0);

        final currentMs = state.position.inMilliseconds
            .clamp(0, maxMs.toInt())
            .toDouble();

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

            GestureDetector(
              onTap: cubit.togglePlayPause,
              child: Container(
                color: Colors.black.withValues(
                  alpha: state.isPlaying ? 0 : 0.25,
                ),
                alignment: Alignment.center,
                child: AnimatedOpacity(
                  opacity: state.isPlaying ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.play_circle_fill,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

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
                child: Row(
                  children: [
                    Text(
                      _formatDuration(state.position),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12,
                          ),
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: currentMs,
                          min: 0,
                          max: maxMs,
                          onChanged: (v) =>
                              cubit.seekTo(Duration(milliseconds: v.round())),
                        ),
                      ),
                    ),
                    Text(
                      _formatDuration(state.duration),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
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
