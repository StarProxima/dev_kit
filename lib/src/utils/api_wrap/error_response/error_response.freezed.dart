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
mixin _$RequestError {
  Object get error => throw _privateConstructorUsedError;
  int get statusCode => throw _privateConstructorUsedError;
  String get method => throw _privateConstructorUsedError;
  Uri get url => throw _privateConstructorUsedError;
  StackTrace get stackTrace => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RequestErrorCopyWith<RequestError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestErrorCopyWith<$Res> {
  factory $RequestErrorCopyWith(
          RequestError value, $Res Function(RequestError) then) =
      _$RequestErrorCopyWithImpl<$Res, RequestError>;
  @useResult
  $Res call(
      {Object error,
      int statusCode,
      String method,
      Uri url,
      StackTrace stackTrace});
}

/// @nodoc
class _$RequestErrorCopyWithImpl<$Res, $Val extends RequestError>
    implements $RequestErrorCopyWith<$Res> {
  _$RequestErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
    Object? statusCode = null,
    Object? method = null,
    Object? url = null,
    Object? stackTrace = null,
  }) {
    return _then(_value.copyWith(
      error: null == error ? _value.error : error,
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
abstract class _$$RequestErrorImplCopyWith<$Res>
    implements $RequestErrorCopyWith<$Res> {
  factory _$$RequestErrorImplCopyWith(
          _$RequestErrorImpl value, $Res Function(_$RequestErrorImpl) then) =
      __$$RequestErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Object error,
      int statusCode,
      String method,
      Uri url,
      StackTrace stackTrace});
}

/// @nodoc
class __$$RequestErrorImplCopyWithImpl<$Res>
    extends _$RequestErrorCopyWithImpl<$Res, _$RequestErrorImpl>
    implements _$$RequestErrorImplCopyWith<$Res> {
  __$$RequestErrorImplCopyWithImpl(
      _$RequestErrorImpl _value, $Res Function(_$RequestErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
    Object? statusCode = null,
    Object? method = null,
    Object? url = null,
    Object? stackTrace = null,
  }) {
    return _then(_$RequestErrorImpl(
      error: null == error ? _value.error : error,
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

class _$RequestErrorImpl implements _RequestError {
  _$RequestErrorImpl(
      {required this.error,
      required this.statusCode,
      required this.method,
      required this.url,
      required this.stackTrace});

  @override
  final Object error;
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
    return 'RequestError(error: $error, statusCode: $statusCode, method: $method, url: $url, stackTrace: $stackTrace)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequestErrorImpl &&
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
  _$$RequestErrorImplCopyWith<_$RequestErrorImpl> get copyWith =>
      __$$RequestErrorImplCopyWithImpl<_$RequestErrorImpl>(this, _$identity);
}

abstract class _RequestError implements RequestError {
  factory _RequestError(
      {required final Object error,
      required final int statusCode,
      required final String method,
      required final Uri url,
      required final StackTrace stackTrace}) = _$RequestErrorImpl;

  @override
  Object get error;
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
  _$$RequestErrorImplCopyWith<_$RequestErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$InternalError {
  Object get error => throw _privateConstructorUsedError;
  StackTrace get stackTrace => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $InternalErrorCopyWith<InternalError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InternalErrorCopyWith<$Res> {
  factory $InternalErrorCopyWith(
          InternalError value, $Res Function(InternalError) then) =
      _$InternalErrorCopyWithImpl<$Res, InternalError>;
  @useResult
  $Res call({Object error, StackTrace stackTrace});
}

/// @nodoc
class _$InternalErrorCopyWithImpl<$Res, $Val extends InternalError>
    implements $InternalErrorCopyWith<$Res> {
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
abstract class _$$InternalErrorImplCopyWith<$Res>
    implements $InternalErrorCopyWith<$Res> {
  factory _$$InternalErrorImplCopyWith(
          _$InternalErrorImpl value, $Res Function(_$InternalErrorImpl) then) =
      __$$InternalErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Object error, StackTrace stackTrace});
}

/// @nodoc
class __$$InternalErrorImplCopyWithImpl<$Res>
    extends _$InternalErrorCopyWithImpl<$Res, _$InternalErrorImpl>
    implements _$$InternalErrorImplCopyWith<$Res> {
  __$$InternalErrorImplCopyWithImpl(
      _$InternalErrorImpl _value, $Res Function(_$InternalErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
    Object? stackTrace = null,
  }) {
    return _then(_$InternalErrorImpl(
      error: null == error ? _value.error : error,
      stackTrace: null == stackTrace
          ? _value.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as StackTrace,
    ));
  }
}

/// @nodoc

class _$InternalErrorImpl implements _InternalError {
  _$InternalErrorImpl({required this.error, required this.stackTrace});

  @override
  final Object error;
  @override
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'InternalError(error: $error, stackTrace: $stackTrace)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InternalErrorImpl &&
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
  _$$InternalErrorImplCopyWith<_$InternalErrorImpl> get copyWith =>
      __$$InternalErrorImplCopyWithImpl<_$InternalErrorImpl>(this, _$identity);
}

abstract class _InternalError implements InternalError {
  factory _InternalError(
      {required final Object error,
      required final StackTrace stackTrace}) = _$InternalErrorImpl;

  @override
  Object get error;
  @override
  StackTrace get stackTrace;
  @override
  @JsonKey(ignore: true)
  _$$InternalErrorImplCopyWith<_$InternalErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
