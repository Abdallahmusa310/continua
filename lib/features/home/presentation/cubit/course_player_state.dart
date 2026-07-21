import 'package:equatable/equatable.dart';

abstract class CoursePlayerState extends Equatable {
  const CoursePlayerState();

  @override
  List<Object?> get props => [];
}

class CoursePlayerInitial extends CoursePlayerState {
  const CoursePlayerInitial();
}

class CoursePlayerLoading extends CoursePlayerState {
  const CoursePlayerLoading();
}

class CoursePlayerReady extends CoursePlayerState {
  final Duration position;
  final Duration duration;
  final bool isPlaying;

  const CoursePlayerReady({
    required this.position,
    required this.duration,
    required this.isPlaying,
  });

  @override
  List<Object?> get props => [position, duration, isPlaying];
}

class CoursePlayerError extends CoursePlayerState {
  final String message;

  const CoursePlayerError(this.message);

  @override
  List<Object?> get props => [message];
}
