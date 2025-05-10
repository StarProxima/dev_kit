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
  () => api.getData(), // Dio request in repository
  minExecutionTime: Duration(milliseconds: 300),   // No UI flicker
  retry: Retry(maxAttempts: 3),                    // Auto-retry on network issues
  rateLimiter: Debounce(duration: Duration(milliseconds: 300)),  // Rate control
  onSuccess: (data) {
    // Optionally transform or use part of the response
    final data = data.someData;
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

### `handle` vs `handleStrict`: Choosing the Right Tool

Handler offers two primary methods for executing your operations: `handle` and `handleStrict`. Understanding their differences will help you write cleaner and more predictable code.

**1. `handle<T, D>(...) -> FutureOr<D?>`**

   - **Use Case**: Ideal when the operation might not return a meaningful value upon success, or when `onError` can provide a fallback value. It's also suitable if `onSuccess` is mainly for side-effects (like updating UI) and doesn't need to return a specific value.
   - **Return Type**: `FutureOr<D?>` (nullable). This means the result `D` can be `null`.
   - **Behavior**:
     - If `onSuccess` is provided, it can transform the original result `T` into `D`. If `onSuccess` is not provided or returns `null`, the result will be `null` (or the value from `onError` if it provides one).
     - If `onError` is provided and returns a value of type `D?`, that value will be the result in case of an error. Otherwise, if `onError` doesn't return a value or isn't provided, the global error handler runs, and `handle` resolves to `null`.

   **When to use `handle`:**
   - Executing "fire-and-forget" operations (e.g., a POST request that doesn't return data).
   - When `onSuccess` is used for side-effects and doesn't need to return a value.
   - When you have a specific fallback value to return from `onError` in certain error scenarios.

**2. `handleStrict<T, D>(...) -> Future<D>`**

   - **Use Case**: Essential when a successful operation **must** produce a non-null value of type `D`. This method enforces stricter type safety.
   - **Return Type**: `Future<D>` (non-nullable). The result `D` is guaranteed to be non-null if the operation succeeds.
   - **Behavior**:
     - `onSuccess` is **required** and *must* return a non-null value of type `D`.
     - If `onError` is not provided, any error encountered (after global error processing) will be **re-thrown**, halting further execution in the current chain. This ensures that you explicitly handle errors or let them propagate.
     - If `onError` *is* provided, it *must* return a non-null value of type `D` to satisfy the non-nullable return type of `handleStrict`.

   **When to use `handleStrict`:**
   - Fetching data that is crucial for subsequent logic and must be non-null.
   - Chaining operations where each step depends on a non-null result from the previous one.
   - When you want to ensure that any unhandled error (by a local `onError`) aggressively stops the execution flow by re-throwing.

In summary:
- Choose `handle` for flexibility, nullable results, and side-effect-driven success handlers.
- Choose `handleStrict` for robust, non-nullable results and when errors should either be explicitly handled to return a valid `D` or halt execution.

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
