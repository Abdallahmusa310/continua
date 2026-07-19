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
  const CoursePlayerReady();
}

class CoursePlayerError extends CoursePlayerState {
  final String message;

  const CoursePlayerError(this.message);

  @override
  List<Object?> get props => [message];
}
