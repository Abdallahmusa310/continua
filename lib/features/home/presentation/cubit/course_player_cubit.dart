import 'dart:async';
import 'package:chewie/chewie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _wasOffline = false;
  bool _isHandlingError = false;

  CoursePlayerCubit({
    required this.getCourseProgressUsecase,
    required this.saveCourseProgressUsecase,
  }) : super(const CoursePlayerInitial()) {
    _listenToConnectivity();
  }

  Future<void> initialize({
    required String courseId,
    required String videoUrl,
    int fallbackDurationSeconds = 0,
  }) async {
    _courseId = courseId;
    _videoUrl = videoUrl;
    _fallbackDuration = Duration(seconds: fallbackDurationSeconds);
    _isHandlingError = false;

    emit(const CoursePlayerLoading());

    try {
      // 0. Check connectivity first — before attempting to load anything
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnection = !connectivityResult.contains(
        ConnectivityResult.none,
      );

      if (!hasConnection) {
        if (isClosed) return;
        emit(
          const CoursePlayerError(
            'No internet connection. Please check your network and try again.',
          ),
        );
        return;
      }

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
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControlsOnInitialize: false,
        aspectRatio: 16 / 9,
        playbackSpeeds: const [0.5, 1.0, 1.25, 1.5, 2.0],
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xff9B5DE5),
          bufferedColor: Colors.white54,
          backgroundColor: Colors.white24,
          handleColor: const Color(0xff9B5DE5),
        ),
      );

      controller = newController;
      chewieController = newChewieController;

      newController.addListener(_onVideoTick);
      _startAutoSaveTimer();
      _emitReady();
    } catch (e) {
      if (isClosed) return;
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnection = !connectivityResult.contains(
        ConnectivityResult.none,
      );

      if (isClosed) return;

      emit(
        CoursePlayerError(
          hasConnection
              ? 'This video could not be loaded. Please try again.'
              : 'No internet connection. Please check your network and try again.',
        ),
      );
    }
  }

  /// is always accurate; only `duration` needs this fallback.
  Duration get _effectiveDuration {
    if (_fallbackDuration > Duration.zero) {
      return _fallbackDuration;
    }
    return controller?.value.duration ?? Duration.zero;
  }

  void _onVideoTick() {
    if (isClosed || _isHandlingError) return;

    final c = controller;

    if (c != null && c.value.hasError) {
      _isHandlingError = true;
      _persistProgress();
      emit(const CoursePlayerError('Connection lost. Please try again.'));
      return;
    }

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

  void _listenToConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) async {
      final isOffline =
          results.isEmpty || results.every((r) => r == ConnectivityResult.none);

      // النت قطع فعليًا وإحنا وسط تشغيل — نظهر رسالة الخطأ فورًا،
      // مش منستنى المشغل يعترف بمشكلة (غالبًا مش هيعترف أصلًا وقت buffering)
      if (isOffline && !_wasOffline && state is CoursePlayerReady) {
        await _persistProgress();
        if (!isClosed) {
          emit(const CoursePlayerError('Connection lost. Please try again.'));
        }
      }

      // النت رجع وكنا في حالة Error — نعيد المحاولة تلقائيًا
      if (_wasOffline && !isOffline && state is CoursePlayerError) {
        await retry();
      }

      _wasOffline = isOffline;
    });
  }

  /// Retry with the same courseId/videoUrl/fallback duration already stored
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
    if (durationSeconds == 0) return; // no real or fallback duration known

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
    await _connectivitySubscription?.cancel();
    return super.close();
  }
}
