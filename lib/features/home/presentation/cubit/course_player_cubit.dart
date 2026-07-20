import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:continua/core/const/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../../home/domain/entities/course_progress_entity.dart';
import '../../../home/domain/usecases/get_course_progress_usecase.dart';
import '../../../home/domain/usecases/save_course_progress_usecase.dart';
import 'course_player_state.dart';

class CoursePlayerCubit extends Cubit<CoursePlayerState> {
  final GetCourseProgressUsecase getCourseProgressUsecase;
  final SaveCourseProgressUsecase saveCourseProgressUsecase;

  VideoPlayerController? controller;
  ChewieController? chewieController;

  Timer? _saveTimer;
  String? _courseId;
  String? _videoUrl;

  CoursePlayerCubit({
    required this.getCourseProgressUsecase,
    required this.saveCourseProgressUsecase,
  }) : super(const CoursePlayerInitial());

  Future<void> initialize({
    required String courseId,
    required String videoUrl,
  }) async {
    _courseId = courseId;
    _videoUrl = videoUrl;

    emit(const CoursePlayerLoading());

    try {
      final progressResult = await getCourseProgressUsecase(courseId);
      if (isClosed) return;

      final savedProgress = progressResult.fold(
        (failure) => CourseProgressEntity.empty(courseId),
        (progress) => progress,
      );

      // 2. جهّز الفيديو من الشبكة مباشرة (streaming)
      final newController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );
      await newController.initialize();

      if (isClosed) {
        await newController.dispose();
        return;
      }

      // 3. لو فيه progress محفوظ ومش completed، اعمل seek لآخر نقطة
      if (!savedProgress.isCompleted && savedProgress.positionSeconds > 0) {
        await newController.seekTo(
          Duration(seconds: savedProgress.positionSeconds),
        );

        if (isClosed) {
          await newController.dispose();
          return;
        }
      }

      final newChewieController = ChewieController(
        videoPlayerController: newController,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControlsOnInitialize: false,
        playbackSpeeds: const [0.5, 1.0, 1.25, 1.5, 2.0],
        materialProgressColors: ChewieProgressColors(
          playedColor: Appcolor.primarycolor,
          bufferedColor: Colors.white54,
          backgroundColor: Colors.white24,
          handleColor: Appcolor.primarycolor,
        ),
        deviceOrientationsOnEnterFullScreen: const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: const [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
      );

      controller = newController;
      chewieController = newChewieController;
      _startAutoSaveTimer();

      emit(const CoursePlayerReady());
    } catch (e) {
      if (isClosed) return;
      emit(const CoursePlayerError('الفيديو مقدرش يتحمل، حاول تاني'));
    }
  }

  Future<void> retry() async {
    if (_courseId == null || _videoUrl == null) return;
    await _disposePlayers();
    await initialize(courseId: _courseId!, videoUrl: _videoUrl!);
  }

  void _startAutoSaveTimer() {
    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _persistProgress(),
    );
  }

  Future<void> togglePlayPause() async {
    final c = controller;
    if (c == null || !c.value.isInitialized) return;

    if (c.value.isPlaying) {
      await c.pause();
      await _persistProgress();
    } else {
      await c.play();
    }
  }

  Future<void> _persistProgress() async {
    final c = controller;
    final courseId = _courseId;
    if (c == null || courseId == null || !c.value.isInitialized) return;

    final durationSeconds = c.value.duration.inSeconds;
    if (durationSeconds == 0) return;

    final positionSeconds = c.value.position.inSeconds;
    final percent = (positionSeconds / durationSeconds * 100)
        .clamp(0, 100)
        .toDouble();

    final progress = CourseProgressEntity(
      courseId: courseId,
      positionSeconds: positionSeconds,
      percent: percent,
      updatedAt: DateTime.now(),
    );

    await saveCourseProgressUsecase(progress);
  }

  Future<void> _disposePlayers() async {
    _saveTimer?.cancel();
    chewieController?.dispose();
    chewieController = null;
    await controller?.dispose();
    controller = null;
  }

  @override
  Future<void> close() async {
    await _persistProgress(); // حفظ أخير وقت الخروج من الشاشة
    await _disposePlayers();
    return super.close();
  }
}
