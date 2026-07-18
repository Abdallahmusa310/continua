import 'package:equatable/equatable.dart';

class CourseEntity extends Equatable {
  final String id;
  final String title;
  final String thumbnailUrl;
  final int durationSeconds;
  final String description;
  final String videoUrl;

  const CourseEntity({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.durationSeconds,
    required this.description,
    required this.videoUrl,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    thumbnailUrl,
    durationSeconds,
    description,
    videoUrl,
  ];
}
