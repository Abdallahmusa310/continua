import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/course_progress_model.dart';

abstract class ProgressLocalDataSource {
  /// بيرجع null لو الكورس ده لسه ملوش أي progress محفوظ
  Future<CourseProgressModel?> getProgress(String courseId);

  Future<void> saveProgress(CourseProgressModel progress);
}

class ProgressLocalDataSourceImpl implements ProgressLocalDataSource {
  final Box<CourseProgressModel> box;

  const ProgressLocalDataSourceImpl(this.box);

  @override
  Future<CourseProgressModel?> getProgress(String courseId) async {
    try {
      return box.get(courseId);
    } catch (e) {
      throw const CacheException();
    }
  }

  @override
  Future<void> saveProgress(CourseProgressModel progress) async {
    try {
      await box.put(progress.hiveCourseId, progress);
    } catch (e) {
      throw const CacheException();
    }
  }
}
