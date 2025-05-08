import 'dart:async';

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
    handle(() => null);
  }

  @override
  // TODO: implement handler
  Handler get handler => throw UnimplementedError();
}
