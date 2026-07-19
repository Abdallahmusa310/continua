import 'package:continua/core/error/exceptions.dart';
import 'package:continua/core/error/failures.dart';
import 'package:continua/features/home/data/datasources/course_local_datasource.dart';
import 'package:continua/features/home/data/datasources/progress_local_datasource.dart';
import 'package:continua/features/home/data/models/course_progress_model.dart';
import 'package:continua/features/home/data/repositories/course_repository_impl.dart';
import 'package:continua/features/home/domain/entities/course_progress_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCourseLocalDataSource extends Mock implements CourseLocalDataSource {}

class MockProgressLocalDataSource extends Mock
    implements ProgressLocalDataSource {}

class FakeCourseProgressModel extends Fake implements CourseProgressModel {}

void main() {
  late CourseRepositoryImpl repository;
  late MockCourseLocalDataSource mockCourseLocalDataSource;
  late MockProgressLocalDataSource mockProgressLocalDataSource;

  setUpAll(() {
    registerFallbackValue(FakeCourseProgressModel());
  });

  setUp(() {
    mockCourseLocalDataSource = MockCourseLocalDataSource();
    mockProgressLocalDataSource = MockProgressLocalDataSource();
    repository = CourseRepositoryImpl(
      courseLocalDataSource: mockCourseLocalDataSource,
      progressLocalDataSource: mockProgressLocalDataSource,
    );
  });

  group('getCourseProgress (resume logic — read path)', () {
    const courseId = 'c001';

    test('returns Right(empty progress) when no progress is cached yet '
        '(first time opening a course, not an error)', () async {
      when(
        () => mockProgressLocalDataSource.getProgress(courseId),
      ).thenAnswer((_) async => null);

      final result = await repository.getCourseProgress(courseId);

      expect(result.isRight(), isTrue);
      result.fold((failure) => fail('expected Right, got Left($failure)'), (
        progress,
      ) {
        expect(progress.courseId, courseId);
        expect(progress.positionSeconds, 0);
        expect(progress.percent, 0.0);
      });
    });

    test(
      'returns Right(saved progress) when a previous position is cached',
      () async {
        final savedModel = CourseProgressModel(
          hiveCourseId: courseId,
          hivePositionSeconds: 15,
          hivePercent: 50.0,
          hiveUpdatedAt: DateTime(2026, 1, 1),
        );

        when(
          () => mockProgressLocalDataSource.getProgress(courseId),
        ).thenAnswer((_) async => savedModel);

        final result = await repository.getCourseProgress(courseId);

        expect(result.isRight(), isTrue);
        result.fold((failure) => fail('expected Right, got Left($failure)'), (
          progress,
        ) {
          expect(progress.positionSeconds, 15);
          expect(progress.percent, 50.0);
          expect(progress.isCompleted, isFalse);
        });
      },
    );

    test('returns Left(CacheFailure) when the datasource throws', () async {
      when(
        () => mockProgressLocalDataSource.getProgress(courseId),
      ).thenThrow(const CacheException());

      final result = await repository.getCourseProgress(courseId);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (progress) => fail('expected Left, got Right($progress)'),
      );
    });
  });

  group('saveCourseProgress (resume logic — write path)', () {
    test(
      'converts entity to model and forwards it to the datasource',
      () async {
        final entity = CourseProgressEntity(
          courseId: 'c001',
          positionSeconds: 20,
          percent: 66.7,
          updatedAt: DateTime(2026, 1, 1),
        );

        when(
          () => mockProgressLocalDataSource.saveProgress(any()),
        ).thenAnswer((_) async {});

        final result = await repository.saveCourseProgress(entity);

        expect(result.isRight(), isTrue);
        final captured =
            verify(
                  () => mockProgressLocalDataSource.saveProgress(captureAny()),
                ).captured.single
                as CourseProgressModel;

        expect(captured.hiveCourseId, 'c001');
        expect(captured.hivePositionSeconds, 20);
        expect(captured.hivePercent, 66.7);
      },
    );

    test('returns Left(CacheFailure) when saving throws', () async {
      final entity = CourseProgressEntity.empty('c001');

      when(
        () => mockProgressLocalDataSource.saveProgress(any()),
      ).thenThrow(const CacheException());

      final result = await repository.saveCourseProgress(entity);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('expected Left, got Right'),
      );
    });
  });
}
