import 'package:continua/features/home/domain/entities/course_progress_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CourseProgressEntity', () {
    test('isCompleted is false when percent is below 95', () {
      final progress = CourseProgressEntity(
        courseId: 'c001',
        positionSeconds: 10,
        percent: 94.9,
        updatedAt: DateTime.now(),
      );

      expect(progress.isCompleted, isFalse);
    });

    test('isCompleted is true when percent is exactly 95', () {
      final progress = CourseProgressEntity(
        courseId: 'c001',
        positionSeconds: 28,
        percent: 95.0,
        updatedAt: DateTime.now(),
      );

      expect(progress.isCompleted, isTrue);
    });

    test('isCompleted is true when percent is above 95', () {
      final progress = CourseProgressEntity(
        courseId: 'c001',
        positionSeconds: 30,
        percent: 100.0,
        updatedAt: DateTime.now(),
      );

      expect(progress.isCompleted, isTrue);
    });

    test('empty() factory returns zeroed progress for the given courseId', () {
      final progress = CourseProgressEntity.empty('c002');

      expect(progress.courseId, 'c002');
      expect(progress.positionSeconds, 0);
      expect(progress.percent, 0.0);
      expect(progress.isCompleted, isFalse);
    });

    test('two entities with same values are equal (Equatable)', () {
      final now = DateTime(2026, 1, 1);
      final a = CourseProgressEntity(
        courseId: 'c003',
        positionSeconds: 12,
        percent: 40.0,
        updatedAt: now,
      );
      final b = CourseProgressEntity(
        courseId: 'c003',
        positionSeconds: 12,
        percent: 40.0,
        updatedAt: now,
      );

      expect(a, equals(b));
    });
  });
}
