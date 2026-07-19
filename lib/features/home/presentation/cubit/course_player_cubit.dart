import 'dart:async';
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
      // 1. هات آخر نقطة وقف عندها المستخدم (لو موجودة)
      final progressResult = await getCourseProgressUsecase(courseId);
      if (isClosed) return; // الشاشة اتقفلت وإحنا لسه بنستنى نتيجة async

      final savedProgress = progressResult.fold(
        (failure) => CourseProgressEntity.empty(courseId),
        (progress) => progress,
      );

      // 2. جهّز الفيديو
      final newController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );
      await newController.initialize();

      if (isClosed) {
        // الشاشة اتقفلت وإحنا لسه بنحمل الفيديو — نضف الـ controller ومنعملش emit
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

      controller = newController;
      _startAutoSaveTimer();

      emit(const CoursePlayerReady());
    } catch (e) {
      if (isClosed) return;
      emit(const CoursePlayerError('الفيديو مقدرش يتحمل، حاول تاني'));
    }
  }

  /// إعادة محاولة تحميل نفس الفيديو (edge case: فشل تحميل الفيديو)
  Future<void> retry() async {
    if (_courseId == null || _videoUrl == null) return;
    await initialize(courseId: _courseId!, videoUrl: _videoUrl!);
  }

  void _startAutoSaveTimer() {
    _saveTimer?.cancel();
    // بنحفظ الـ progress كل 3 ثواني وقت التشغيل، مش كل frame
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
      await _persistProgress(); // بنحفظ فوراً وقت الـ pause
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

    // مفيش emit هنا خالص، فمحتاجاش isClosed check — بس الحفظ نفسه آمن يتنفذ
    // حتى لو الـ Cubit في طريقه للإغلاق (بيتنادى من close() كمان)
    await saveCourseProgressUsecase(progress);
  }

  @override
  Future<void> close() async {
    _saveTimer?.cancel();
    await _persistProgress(); // حفظ أخير وقت الخروج من الشاشة
    await controller?.dispose();
    return super.close();
  }
}
