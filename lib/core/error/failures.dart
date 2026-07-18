import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'مفيش اتصال بالإنترنت، حاول تاني'])
    : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'حصل خطأ في قراءة البيانات المحفوظة'])
    : super(message);
}

class PlaybackFailure extends Failure {
  const PlaybackFailure([String message = 'الفيديو مقدرش يتحمل، حاول تاني'])
    : super(message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([String message = 'حصل خطأ غير متوقع'])
    : super(message);
}
