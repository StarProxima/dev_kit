part of 'api_wrap.dart';

final _rand = math.Random();

bool _defaultRetryIf(ApiError e) {
  if (e is! InternalError) return false;

  return switch (e.error) {
    DioException(type: DioExceptionType.badResponse) => false,
    DioException() => true,
    SocketException() || TimeoutException() => true,
    _ => false,
  };
}

typedef RetryIf<ErrorType> = FutureOr<bool> Function(ApiError<ErrorType> error);

class Retry<ErrorType> {
  Retry({
    required this.maxAttempts,
    this.retryIf = _defaultRetryIf,
    this.delayFactor = const Duration(milliseconds: 500),
    this.minDelay = Duration.zero,
    this.maxDelay = const Duration(seconds: 10),
    this.randomizationFactor = 0.25,
  });

  final RetryIf<ErrorType> retryIf;
  final int maxAttempts;
  final Duration delayFactor;
  final Duration minDelay;
  final Duration maxDelay;
  final double randomizationFactor;

  Duration calculateDelay(int attempt) {
    final rf = randomizationFactor * (_rand.nextDouble() * 2 - 1) + 1;
    final exp = math.min(attempt, 31);
    final delay = minDelay + delayFactor * math.pow(2.0, exp) * rf;
    final resultDelay = delay < maxDelay ? delay : maxDelay;

    return resultDelay;
  }
}
