import 'package:continua/features/home/domain/entities/course_entity.dart';
import 'package:continua/features/home/presentation/screens/widgets/courses_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const testCourse = CourseEntity(
    id: 'c001',
    title: 'Intro to UI/UX Design',
    thumbnailUrl: 'https://picsum.photos/seed/course1/400/225',
    durationSeconds: 30,
    description: 'A short primer on UI/UX fundamentals.',
    videoUrl: 'https://cdn.pixabay.com/video/2026/07/10/363199_large.mp4',
  );

  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('shows title and description regardless of progress', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(CoursesCard(course: testCourse, progressPercent: 0, onTap: () {})),
    );

    expect(find.text('Intro to UI/UX Design'), findsOneWidget);
    expect(find.text('A short primer on UI/UX fundamentals.'), findsOneWidget);
  });

  testWidgets(
    'shows "Start Learning" and no percentage text when progress is 0',
    (tester) async {
      await tester.pumpWidget(
        wrap(CoursesCard(course: testCourse, progressPercent: 0, onTap: () {})),
      );

      expect(find.text('Start Learning'), findsOneWidget);
      expect(find.text('0%'), findsNothing);
    },
  );

  testWidgets(
    'shows the rounded percentage text when progress is greater than 0',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          CoursesCard(course: testCourse, progressPercent: 42.0, onTap: () {}),
        ),
      );

      expect(find.text('42%'), findsOneWidget);
      expect(find.text('Start course'), findsNothing);
    },
  );

  testWidgets('calls onTap when the card is tapped', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      wrap(
        CoursesCard(
          course: testCourse,
          progressPercent: 10,
          onTap: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.byType(CoursesCard));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
