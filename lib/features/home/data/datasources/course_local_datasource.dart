import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../../../core/error/exceptions.dart';
import '../models/course_model.dart';

abstract class CourseLocalDataSource {
  Future<List<CourseModel>> getCourses();
}

class CourseLocalDataSourceImpl implements CourseLocalDataSource {
  static const _assetPath = 'assets/courses.json';

  @override
  Future<List<CourseModel>> getCourses() async {
    try {
      await Future.delayed(const Duration(milliseconds:500));
      final raw = await rootBundle.loadString(_assetPath);
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final coursesJson = decoded['courses'] as List<dynamic>;

      return coursesJson
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw const CacheException('فشل تحميل الكورسات');
    }
  }
}