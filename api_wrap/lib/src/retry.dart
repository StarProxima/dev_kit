part of 'api_wrap.dart';

final _rand = math.Random();

bool _alwaysRetryIf(ApiError e) => true;

bool _connectionRetryIf(ApiError e) {
  if (e is! InternalError) return false;
  final error = e.error;
  return switch (error) {
    DioException(type: DioExceptionType.badResponse) => false,
    DioException(requestOptions: RequestOptions(method: 'GET')) => true,
    SocketException() || TimeoutException() => true,
    _ => false,
  };
}

typedef RetryIf<ErrorType> = FutureOr<bool> Function(ApiError<ErrorType> e);

class Retry<ErrorType> {
  const Retry({
    required this.maxAttempts,
    this.retryIf = _alwaysRetryIf,
    this.onError,
    this.delayFactor = const Duration(milliseconds: 500),
    this.minDelay = Duration.zero,
    this.maxDelay = const Duration(seconds: 10),
    this.randomizationFactor = 0.25,
  }) : assert(maxAttempts > 0, 'maxAttempts must be greater than 0');

  // Without retry
  factory Retry.no() => Retry(maxAttempts: 1);

  /// Retry for Dio connection errors
  const Retry.connection({
    this.maxAttempts = 3,
    this.retryIf = _connectionRetryIf,
    this.onError,
    this.delayFactor = const Duration(milliseconds: 500),
    this.minDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 10),
    this.randomizationFactor = 0.25,
  }) : assert(maxAttempts > 0, 'maxAttempts must be greater than 0');

  final RetryIf<ErrorType> retryIf;
  final FutureOr<void> Function(
    ApiError<ErrorType> e,
    Duration delayBeforeNextAttemt,
  )? onError;
  final int maxAttempts;
  final Duration delayFactor;
  final Duration minDelay;
  final Duration maxDelay;
  final double randomizationFactor;

  Duration calculateDelay(int attempt) {
    assert(maxAttempts > 0, 'maxAttempts must be greater than 0');

    final rf = randomizationFactor * (_rand.nextDouble() * 2 - 1) + 1;
    final exp = math.min(attempt, 31);
    final delay = minDelay + delayFactor * math.pow(2.0, exp) * rf;
    final resultDelay = delay < maxDelay ? delay : maxDelay;

    return resultDelay;
  }
}
