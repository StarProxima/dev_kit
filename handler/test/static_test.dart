import 'dart:async';

import 'package:dio/dio.dart';
import 'package:handler/handler.dart';

class AppHandler extends Handler<int> {
  AppHandler()
      : super(
          retry: Retry.none(),
          onError: (e) {},
          parseBaseResponseError: (e) => 0,
        );

  @override
  FutureOr<void> onError(
    HandledError<int> error, {
    bool def = false,
  }) {}
}

mixin ControllerMixin implements HandlerFacade {
  void test() {
    final key = '';
    handle(
      () {},
      key: key,
    );
  }
}

class Controller with HandlerFacade {
  void test() {
    handle(
      () => null,
      onError: (e) {
        handler.onError(e);

        switch (e) {
          case ErrorResponse(statusCode: >= 300):
            // Handle 404 error
            break;
          default:
          // Let the default handler do its job for other errors
        }
      },
    );
  }

  @override
  // TODO: implement handler
  Handler get handler => throw UnimplementedError();
}

extension CancelTokenX on Handler {
  CancelToken getCancelToken({Object? key}) {
    throw UnimplementedError();
  }
}

class ControllerWithCancel with ControllerMixin {
  void getData() async {
    await handle(
      () {
        final canlelToken = handler.getCancelToken(key: #getData);
        // dio api request with canlelToken

        if (canlelToken.isCancelled) {
          throw CancelError.withStackTrace();
        }

        // async logic

        if (canlelToken.isCancelled) {
          throw CancelError.withStackTrace();
        }

        // another dio api request with canlelToken
      },
      key: #getData,
      onError: (e) {
        handler.onError(e);
      },
    );
  }

  void cancelGetData() {
    handler.cancel(key: #getData);
  }

  void dispose() {
    handler.cancelAll();
  }

  @override
  // TODO: implement handler
  Handler get handler => throw UnimplementedError();
}
