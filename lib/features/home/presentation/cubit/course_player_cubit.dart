import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';

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
  Duration _fallbackDuration = Duration.zero;

  CoursePlayerCubit({
    required this.getCourseProgressUsecase,
    required this.saveCourseProgressUsecase,
  }) : super(const CoursePlayerInitial());

  Future<void> initialize({
    required String courseId,
    required String videoUrl,
    int fallbackDurationSeconds = 0,
  }) async {
    debugPrint('DEBUG: fallbackDurationSeconds = $fallbackDurationSeconds');
    _courseId = courseId;
    _videoUrl = videoUrl;
    _fallbackDuration = Duration(seconds: fallbackDurationSeconds);

    emit(const CoursePlayerLoading());

    try {
      final progressResult = await getCourseProgressUsecase(courseId);
      if (isClosed) return;

      final savedProgress = progressResult.fold(
        (failure) => CourseProgressEntity.empty(courseId),
        (progress) => progress,
      );

      final newController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );
      await newController.initialize();

      if (isClosed) {
        await newController.dispose();
        return;
      }

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
        showControls: false, // ✅ بنعطّل الـ UI الجاهزة بتاعت Chewie
      );

      controller = newController;
      chewieController = newChewieController;

      newController.addListener(_onVideoTick);
      _startAutoSaveTimer();
      _emitReady();
    } catch (e) {
      if (isClosed) return;
      emit(const CoursePlayerError('الفيديو مقدرش يتحمل، حاول تاني'));
    }
  }

  /// المدة الفعّالة: الحقيقية لو معروفة، وإلا الـ fallback من الـ JSON
  Duration get _effectiveDuration {
    final real = controller?.value.duration ?? Duration.zero;
    return real > Duration.zero ? real : _fallbackDuration;
  }

  void _onVideoTick() {
    if (isClosed) return;
    _emitReady();
  }

  void _emitReady() {
    final c = controller;
    if (c == null || !c.value.isInitialized) return;

    emit(
      CoursePlayerReady(
        position: c.value.position,
        duration: _effectiveDuration,
        isPlaying: c.value.isPlaying,
      ),
    );
  }

  Future<void> retry() async {
    if (_courseId == null || _videoUrl == null) return;
    await _disposePlayers();
    await initialize(
      courseId: _courseId!,
      videoUrl: _videoUrl!,
      fallbackDurationSeconds: _fallbackDuration.inSeconds,
    );
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

  Future<void> seekTo(Duration position) async {
    await controller?.seekTo(position);
  }

  Future<void> setSpeed(double speed) async {
    await controller?.setPlaybackSpeed(speed);
  }

  Future<void> _persistProgress() async {
    final c = controller;
    final courseId = _courseId;
    if (c == null || courseId == null || !c.value.isInitialized) return;

    final durationSeconds = _effectiveDuration.inSeconds;
    if (durationSeconds == 0) return; // مفيش ولا fallback معروف، متسجلش

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
    controller?.removeListener(_onVideoTick);
    chewieController?.dispose();
    chewieController = null;
    await controller?.dispose();
    controller = null;
  }

  @override
  Future<void> close() async {
    await _persistProgress();
    await _disposePlayers();
    return super.close();
  }
}
