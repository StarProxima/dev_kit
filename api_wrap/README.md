# Handler

![Package Thumbnail](https://github.com/user-attachments/assets/2f549930-5647-4361-a53c-92f2bd94b30c)

> **The ultimate solution for robust, clean, and UX-friendly API operations in Flutter apps**

Handler radically simplifies how you work with HTTP requests and async operations by providing a unified API that elegantly solves common challenges:

- ✅ **Error management** - centralized with type safety
- ✅ **Auto-retry** - seamless recovery from failures
- ✅ **Rate-limiting** - optimized frequency control
- ✅ **Operation control** - cancel or trigger operations on demand
- ✅ **Great UX** - smooth loading states and transitions

## Why You'll Love Handler

Every Flutter developer knows the pain of these common API problems:

```dart
// Problems with traditional approach:
try {
  showLoading();
  final response = await dio.get('/endpoint'); // What if network fails?
  hideLoading();                               // What if it's too fast and UI flickers?
  
  if (response.statusCode == 200) {
    final data = MyData.fromJson(response.data);
    updateUI(data);
  } else {
    // Different errors need different handling
    handleApiError(response);                  // Where to put global vs local handling?
  }
} catch (e) {
  hideLoading();                               // Repetitive error state management
  handleNetworkError(e);                       // What if temporary and should retry?
}

// With USER INPUT (even worse!)
// - Need debouncing for search-as-you-type
// - Need throttling for "like" buttons
// - Need cancellation when user navigates away
```

**Handler transforms this mess into elegant, declarative code:**

```dart
// The Handler way:
final result = await handler.handle(
  () => dio.get('/endpoint'),
  minExecutionTime: Duration(milliseconds: 300),   // No UI flicker
  retry: Retry(maxAttempts: 3),                    // Auto-retry on network issues
  rateLimiter: Debounce(duration: Duration(milliseconds: 300)),  // Rate control
  onSuccess: (response) {
    // Optionally transform or use part of the response
    final data = MyData.fromJson(response.data); 
    // No need to return anything from onSuccess if the primary goal is side-effects (e.g., UI update)
  },
  onError: (error) => handleSpecificError(error),  // Local error handling if needed
);

// That's it! Global error handling (logging, analytics, default UI notifications)
// is managed centrally by Handler, keeping your call sites clean.
```

## Powerful Features at a Glance

### 💪 Centralized Error Handling: The Core Superpower

Stop scattering `try-catch` blocks, logging, and error notifications everywhere. Define error handling **once** in your `Handler` and reuse it across your app:

```dart
// In your AppHandler (extends Handler)
class AppHandler extends Handler<MyCustomApiError> {
  AppHandler() : super(
    parseBaseResponseError: (data) => MyCustomApiError.fromData(data),
    // Provide a default global error handler
    onError: (error) {
      // 1. Log every error
      Logger.error("API Operation Failed", error: error.originalError, stackTrace: error.stackTrace);

      // 2. Send to analytics/crash reporting (e.g., Sentry, Firebase)
      switch (error) {
        case InternalError():
        case ErrorResponse(statusCode: >= 500):
          Analytics.reportError(error);
          break;
        default:
          // Do not report other errors like 4xx or cancellations
          break;
      }

      // 3. Show user-friendly notifications (can be customized)
      String errorMessage = "An unexpected error occurred.";
      switch (error) {
        case ErrorResponse(error: final apiError, statusCode: final code):
          errorMessage = "API Error ($code): ${apiError.developerMessage}"; // Assuming MyCustomApiError has a developerMessage
          break;
        case InternalError(error: final internalErr):
          errorMessage = "Internal error: ${internalErr.toString()}";
          break;
        case CancelError():
          errorMessage = "Operation was cancelled.";
          break;
      }
      showErrorToast(errorMessage);
    }
  );

  // Optional: Override onError for more control (e.g., with context or specific params)
  void onError(HandledError<MyCustomApiError> error, {bool showToast = true}) {
    if (showToast) {
      // Your custom toast logic for this specific handler instance
    }
    // You can still call the default global behavior if needed from the constructor
    super.onError(error); 
  }
}

// Now, at the call site, you only care about specific UI updates or fallbacks:
await handler.handle(
  () => userRepository.updateProfile(newData),
  onError: (error) {
    // Maybe this specific error needs a dialog instead of a toast
    switch (error) {
      case ErrorResponse(statusCode: 422, error: final apiError): // Unprocessable Entity
        // Assuming MyCustomApiError has a way to get validation messages
        showValidationDialog(apiError.validationMessages);
        break;
      default:
        // Let the global handler do its job for other errors
        // (or call `handler.onError(error)` if you overrode it and want default behavior)
        break; 
    }
    // No need to return anything if the goal is just specific error UI
  }
);
```

With Handler, you get:
- **Consistency**: All errors are handled uniformly.
- **Cleanliness**: Business logic isn't cluttered with error handling.
- **Maintainability**: Update error logic in one place.

### 🔄 Smart Retry with Strategies

Automatically retry failed operations with intelligent backoff. Customize retry conditions using `HandledError`:

```dart
await handler.handle(
  () => dataService.fetchCriticalData(),
  retry: Retry(
    maxAttempts: 5,
    delayStrategy: DelayStrategy.exponential(), // Exponential backoff with jitter
    retryIf: (e, s, stats) {
      // Use wrapError to work with HandledError types
      final error = handler.wrapError(e, s);
      // Only retry specific API errors or network issues
      return switch (error) {
        ErrorResponse(statusCode: >= 500 || final code == 408) => true, // Server errors or timeout
        InternalError(error: SocketException()) => true, // Potentially network related
        _ => false,
      };
    },
  ),
);
```

### ⏰ Rate Limiting Made Easy

Use `Debounce` for user input or `Throttle` for rapid operations:

```dart
// Search-as-you-type
searchField.onChanged = (query) {
  handler.handle(
    () => repository.searchItems(query),
    key: 'search-operation', // Allows cancellation
    rateLimiter: Debounce(duration: Duration(milliseconds: 300)),
  );
};
```

### `handle` vs `handleStrict`: What's the Difference?

- `FutureOr<D?> handle<T, D>(...)`: Use when the operation can succeed without returning a meaningful value (e.g., a POST request that returns `void` or `null` on success), or when `onError` provides a fallback value, or when `onSuccess` performs side-effects without returning a value. The result type `D?` is nullable.

- `Future<D> handleStrict<T, D>(...)`: Use when a successful operation **must** return a non-null value of type `D`. If `onSuccess` is not provided or returns `null`, and the original function returns `null` or a different type, it will throw. If `onError` is not provided, any error will be re-thrown after global processing. This is useful for ensuring type safety and non-nullability in your data flow.

### 🧩 Elegant Nested Requests

Chain dependent API calls cleanly:

```dart
final orderDetails = await handler.handleStrict(
  () => orderRepository.createOrder(cartItems),
  onSuccess: (orderConfirmation) async {
    showToast('Order created: ${orderConfirmation.orderId}');
    // Second request depends on the first one
    final paymentResult = await handler.handleStrict(
      () => paymentRepository.processPayment(orderConfirmation.orderId, paymentDetails),
      onSuccess: (paymentStatus) => paymentStatus,
    );
    return OrderDetails(order: orderConfirmation, payment: paymentResult);
  },
);
```

### ⚡ Operation Control

Explicitly manage ongoing operations:

```dart
// Cancel pending search if user types quickly or navigates away
handler.cancel(key: 'search-operation');

// For debounce / throttle, fire immediately if needed (e.g. user action)
await handler.fire(key: 'user-action-debounce');

// Cancel all ongoing Handler operations (e.g., on screen dispose)
handler.cancelAll();
```

### `HandledError` Deep Dive

Switch over `HandledError` for precise error management (Dart 3 pattern matching):

```dart
// Inside your custom onError or at the call site
switch (error) {
  case ErrorResponse<MyCustomApiError>(error: final apiErr, statusCode: final code):
    // Access structured error data directly
    print('API Error Code: $code');
    print('Custom Payload: ${apiErr.developerMessage}'); // Your MyCustomApiError payload
    // error.url, error.method, error.requestData are available.
    break;
  case InternalError(error: final internalErr):
    print('Internal error: $internalErr');
    break;
  case CancelError(rateLimiter: final limiter, timings: final timings):
    print('Operation was cancelled. Limiter: ${limiter?.runtimeType}, Timings: $timings');
    break;
}
```
Your custom `BaseResponseError` (e.g., `MyCustomApiError`) only holds the parsed `data` (payload) from the error response. `ErrorResponse` provides access to HTTP details like `statusCode`. 

### 🤝 `HandlerFacade` for Clean Architecture

Use `HandlerFacade` mixin in your Blocs, Cubits, or Notifiers (Riverpod) to keep them clean and focused on state management, delegating API operations to repositories/services accessed via the handler:

```dart
// In your Cubit/Bloc/Notifier
class MyFeatureCubit extends Cubit<MyState> with HandlerFacade<ApiError> {
  @override
  final Handler<ApiError> handler; // Injected or created
  final MyRepository _repository;

  MyFeatureCubit(this.handler, this._repository) : super(InitialState());

  Future<void> fetchData() async {
    emit(LoadingState());
    // Use the handle method directly from the facade!
    // No need to return from onSuccess if it only emits state
    await handle<DataType, void>(
      () => _repository.fetchData(),
      onSuccess: (result) {
        emit(LoadedState(result));
      },
      onError: (error) {
        String friendlyMessage = "Failed to fetch data"; // Default
        // You can customize the message based on error type here if needed
        emit(ErrorState(friendlyMessage));
      },
    );
  }
}
```

## Installation

```yaml
dependencies:
  handler: ^1.0.0
```

## Quick Example: Repository Pattern

It's generally better to call repository methods inside `handler.handle`, not to use Handler directly within repositories.

```dart
// data_repository.dart
class DataRepository {
  Future<MyData> fetchData() async {
    // Actual HTTP call using Dio, http, etc.
    final response = await dio.get('/data');
    return MyData.fromJson(response.data); // Throws if parsing fails or bad response
  }
}

// feature_controller.dart or BLoC/Cubit
class FeatureController {
  final AppHandler handler; // Your customized Handler instance
  final DataRepository repository;

  FeatureController(this.handler, this.repository);

  Future<ViewModel?> loadAndShowData() async {
    final viewModel = await handler.handle<MyData, ViewModel?>(
      () => repository.fetchData(), // Repository method call
      onSuccess: (myData) => ViewModel.fromData(myData), // Map to ViewModel
      // Global error handling from AppHandler will apply
      // Add specific onError here if needed for this call site, 
      // for example, to return a specific ViewModel on a particular error:
      onError: (error) {
        if (error case ErrorResponse(statusCode: 404)) {
          return ViewModel.notFound();
        }

        // Let global handler manage UI for other errors
        handler.onError(error); 
      },
    );
    return viewModel;
  }
}
```

---

## Contributors ✨

[![Alt](https://opencollective.com/dev_kit/contributors.svg?width=890&button=false)](https://github.com/remarkablemark/dev_kit/graphs/contributors)

Contributions of any kind welcome!

## Activities

![Alt](https://repobeats.axiom.co/api/embed/732b41cfc45839e3b078304e6b46ca0da7bd7f15.svg "Repobeats analytics image")
