// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'error_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$RequestError<ErrorType> {
  ErrorType get error => throw _privateConstructorUsedError;
  int get statusCode => throw _privateConstructorUsedError;
  String get method => throw _privateConstructorUsedError;
  Uri get url => throw _privateConstructorUsedError;
  StackTrace get stackTrace => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RequestErrorCopyWith<ErrorType, RequestError<ErrorType>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestErrorCopyWith<ErrorType, $Res> {
  factory $RequestErrorCopyWith(RequestError<ErrorType> value,
          $Res Function(RequestError<ErrorType>) then) =
      _$RequestErrorCopyWithImpl<ErrorType, $Res, RequestError<ErrorType>>;
  @useResult
  $Res call(
      {ErrorType error,
      int statusCode,
      String method,
      Uri url,
      StackTrace stackTrace});
}

/// @nodoc
class _$RequestErrorCopyWithImpl<ErrorType, $Res,
        $Val extends RequestError<ErrorType>>
    implements $RequestErrorCopyWith<ErrorType, $Res> {
  _$RequestErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = freezed,
    Object? statusCode = null,
    Object? method = null,
    Object? url = null,
    Object? stackTrace = null,
  }) {
    return _then(_value.copyWith(
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as ErrorType,
      statusCode: null == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as Uri,
      stackTrace: null == stackTrace
          ? _value.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as StackTrace,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RequestErrorImplCopyWith<ErrorType, $Res>
    implements $RequestErrorCopyWith<ErrorType, $Res> {
  factory _$$RequestErrorImplCopyWith(_$RequestErrorImpl<ErrorType> value,
          $Res Function(_$RequestErrorImpl<ErrorType>) then) =
      __$$RequestErrorImplCopyWithImpl<ErrorType, $Res>;
  @override
  @useResult
  $Res call(
      {ErrorType error,
      int statusCode,
      String method,
      Uri url,
      StackTrace stackTrace});
}

/// @nodoc
class __$$RequestErrorImplCopyWithImpl<ErrorType, $Res>
    extends _$RequestErrorCopyWithImpl<ErrorType, $Res,
        _$RequestErrorImpl<ErrorType>>
    implements _$$RequestErrorImplCopyWith<ErrorType, $Res> {
  __$$RequestErrorImplCopyWithImpl(_$RequestErrorImpl<ErrorType> _value,
      $Res Function(_$RequestErrorImpl<ErrorType>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = freezed,
    Object? statusCode = null,
    Object? method = null,
    Object? url = null,
    Object? stackTrace = null,
  }) {
    return _then(_$RequestErrorImpl<ErrorType>(
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as ErrorType,
      statusCode: null == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as Uri,
      stackTrace: null == stackTrace
          ? _value.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as StackTrace,
    ));
  }
}

/// @nodoc

class _$RequestErrorImpl<ErrorType> implements _RequestError<ErrorType> {
  _$RequestErrorImpl(
      {required this.error,
      required this.statusCode,
      required this.method,
      required this.url,
      required this.stackTrace});

  @override
  final ErrorType error;
  @override
  final int statusCode;
  @override
  final String method;
  @override
  final Uri url;
  @override
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'RequestError<$ErrorType>(error: $error, statusCode: $statusCode, method: $method, url: $url, stackTrace: $stackTrace)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequestErrorImpl<ErrorType> &&
            const DeepCollectionEquality().equals(other.error, error) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(error),
      statusCode,
      method,
      url,
      stackTrace);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RequestErrorImplCopyWith<ErrorType, _$RequestErrorImpl<ErrorType>>
      get copyWith => __$$RequestErrorImplCopyWithImpl<ErrorType,
          _$RequestErrorImpl<ErrorType>>(this, _$identity);
}

abstract class _RequestError<ErrorType> implements RequestError<ErrorType> {
  factory _RequestError(
      {required final ErrorType error,
      required final int statusCode,
      required final String method,
      required final Uri url,
      required final StackTrace stackTrace}) = _$RequestErrorImpl<ErrorType>;

  @override
  ErrorType get error;
  @override
  int get statusCode;
  @override
  String get method;
  @override
  Uri get url;
  @override
  StackTrace get stackTrace;
  @override
  @JsonKey(ignore: true)
  _$$RequestErrorImplCopyWith<ErrorType, _$RequestErrorImpl<ErrorType>>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$InternalError<ErrorType> {
  Object get error => throw _privateConstructorUsedError;
  StackTrace get stackTrace => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $InternalErrorCopyWith<ErrorType, InternalError<ErrorType>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InternalErrorCopyWith<ErrorType, $Res> {
  factory $InternalErrorCopyWith(InternalError<ErrorType> value,
          $Res Function(InternalError<ErrorType>) then) =
      _$InternalErrorCopyWithImpl<ErrorType, $Res, InternalError<ErrorType>>;
  @useResult
  $Res call({Object error, StackTrace stackTrace});
}

/// @nodoc
class _$InternalErrorCopyWithImpl<ErrorType, $Res,
        $Val extends InternalError<ErrorType>>
    implements $InternalErrorCopyWith<ErrorType, $Res> {
  _$InternalErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
    Object? stackTrace = null,
  }) {
    return _then(_value.copyWith(
      error: null == error ? _value.error : error,
      stackTrace: null == stackTrace
          ? _value.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as StackTrace,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InternalErrorImplCopyWith<ErrorType, $Res>
    implements $InternalErrorCopyWith<ErrorType, $Res> {
  factory _$$InternalErrorImplCopyWith(_$InternalErrorImpl<ErrorType> value,
          $Res Function(_$InternalErrorImpl<ErrorType>) then) =
      __$$InternalErrorImplCopyWithImpl<ErrorType, $Res>;
  @override
  @useResult
  $Res call({Object error, StackTrace stackTrace});
}

/// @nodoc
class __$$InternalErrorImplCopyWithImpl<ErrorType, $Res>
    extends _$InternalErrorCopyWithImpl<ErrorType, $Res,
        _$InternalErrorImpl<ErrorType>>
    implements _$$InternalErrorImplCopyWith<ErrorType, $Res> {
  __$$InternalErrorImplCopyWithImpl(_$InternalErrorImpl<ErrorType> _value,
      $Res Function(_$InternalErrorImpl<ErrorType>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
    Object? stackTrace = null,
  }) {
    return _then(_$InternalErrorImpl<ErrorType>(
      error: null == error ? _value.error : error,
      stackTrace: null == stackTrace
          ? _value.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as StackTrace,
    ));
  }
}

/// @nodoc

class _$InternalErrorImpl<ErrorType> implements _InternalError<ErrorType> {
  _$InternalErrorImpl({required this.error, required this.stackTrace});

  @override
  final Object error;
  @override
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'InternalError<$ErrorType>(error: $error, stackTrace: $stackTrace)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InternalErrorImpl<ErrorType> &&
            const DeepCollectionEquality().equals(other.error, error) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(error), stackTrace);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InternalErrorImplCopyWith<ErrorType, _$InternalErrorImpl<ErrorType>>
      get copyWith => __$$InternalErrorImplCopyWithImpl<ErrorType,
          _$InternalErrorImpl<ErrorType>>(this, _$identity);
}

abstract class _InternalError<ErrorType> implements InternalError<ErrorType> {
  factory _InternalError(
      {required final Object error,
      required final StackTrace stackTrace}) = _$InternalErrorImpl<ErrorType>;

  @override
  Object get error;
  @override
  StackTrace get stackTrace;
  @override
  @JsonKey(ignore: true)
  _$$InternalErrorImplCopyWith<ErrorType, _$InternalErrorImpl<ErrorType>>
      get copyWith => throw _privateConstructorUsedError;
}
