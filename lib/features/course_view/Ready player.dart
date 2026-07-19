import 'package:chewie/chewie.dart';
import 'package:continua/features/home/presentation/cubit/course_player_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// الفيديو الحقيقي شغال — Chewie بيتولى كل الـ controls
/// (play/pause, progress bar, speed, fullscreen) تلقائيًا
class ReadyPlayer extends StatelessWidget {
  const ReadyPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final chewieController = context.read<CoursePlayerCubit>().chewieController;

    if (chewieController == null) {
      // حالة دفاعية، مفروض معدّيهاش لو الـ state Ready
      return Container(color: Colors.black);
    }

    return Chewie(controller: chewieController);
  }
}
