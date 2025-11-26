// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AttendanceState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<AttendanceModel> attendanceList)
        loadingSuccess,
    required TResult Function(String myError) laodingFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<AttendanceModel> attendanceList)? loadingSuccess,
    TResult? Function(String myError)? laodingFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<AttendanceModel> attendanceList)? loadingSuccess,
    TResult Function(String myError)? laodingFailure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_LoginSuccess value) loadingSuccess,
    required TResult Function(_LoginFailure value) laodingFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_LoginSuccess value)? loadingSuccess,
    TResult? Function(_LoginFailure value)? laodingFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_LoginSuccess value)? loadingSuccess,
    TResult Function(_LoginFailure value)? laodingFailure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceStateCopyWith<$Res> {
  factory $AttendanceStateCopyWith(
          AttendanceState value, $Res Function(AttendanceState) then) =
      _$AttendanceStateCopyWithImpl<$Res, AttendanceState>;
}

/// @nodoc
class _$AttendanceStateCopyWithImpl<$Res, $Val extends AttendanceState>
    implements $AttendanceStateCopyWith<$Res> {
  _$AttendanceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$AttendanceStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'AttendanceState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<AttendanceModel> attendanceList)
        loadingSuccess,
    required TResult Function(String myError) laodingFailure,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<AttendanceModel> attendanceList)? loadingSuccess,
    TResult? Function(String myError)? laodingFailure,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<AttendanceModel> attendanceList)? loadingSuccess,
    TResult Function(String myError)? laodingFailure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_LoginSuccess value) loadingSuccess,
    required TResult Function(_LoginFailure value) laodingFailure,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_LoginSuccess value)? loadingSuccess,
    TResult? Function(_LoginFailure value)? laodingFailure,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_LoginSuccess value)? loadingSuccess,
    TResult Function(_LoginFailure value)? laodingFailure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements AttendanceState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$AttendanceStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'AttendanceState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<AttendanceModel> attendanceList)
        loadingSuccess,
    required TResult Function(String myError) laodingFailure,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<AttendanceModel> attendanceList)? loadingSuccess,
    TResult? Function(String myError)? laodingFailure,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<AttendanceModel> attendanceList)? loadingSuccess,
    TResult Function(String myError)? laodingFailure,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_LoginSuccess value) loadingSuccess,
    required TResult Function(_LoginFailure value) laodingFailure,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_LoginSuccess value)? loadingSuccess,
    TResult? Function(_LoginFailure value)? laodingFailure,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_LoginSuccess value)? loadingSuccess,
    TResult Function(_LoginFailure value)? laodingFailure,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements AttendanceState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$LoginSuccessImplCopyWith<$Res> {
  factory _$$LoginSuccessImplCopyWith(
          _$LoginSuccessImpl value, $Res Function(_$LoginSuccessImpl) then) =
      __$$LoginSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<AttendanceModel> attendanceList});
}

/// @nodoc
class __$$LoginSuccessImplCopyWithImpl<$Res>
    extends _$AttendanceStateCopyWithImpl<$Res, _$LoginSuccessImpl>
    implements _$$LoginSuccessImplCopyWith<$Res> {
  __$$LoginSuccessImplCopyWithImpl(
      _$LoginSuccessImpl _value, $Res Function(_$LoginSuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attendanceList = null,
  }) {
    return _then(_$LoginSuccessImpl(
      null == attendanceList
          ? _value._attendanceList
          : attendanceList // ignore: cast_nullable_to_non_nullable
              as List<AttendanceModel>,
    ));
  }
}

/// @nodoc

class _$LoginSuccessImpl implements _LoginSuccess {
  const _$LoginSuccessImpl(final List<AttendanceModel> attendanceList)
      : _attendanceList = attendanceList;

  final List<AttendanceModel> _attendanceList;
  @override
  List<AttendanceModel> get attendanceList {
    if (_attendanceList is EqualUnmodifiableListView) return _attendanceList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attendanceList);
  }

  @override
  String toString() {
    return 'AttendanceState.loadingSuccess(attendanceList: $attendanceList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginSuccessImpl &&
            const DeepCollectionEquality()
                .equals(other._attendanceList, _attendanceList));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_attendanceList));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginSuccessImplCopyWith<_$LoginSuccessImpl> get copyWith =>
      __$$LoginSuccessImplCopyWithImpl<_$LoginSuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<AttendanceModel> attendanceList)
        loadingSuccess,
    required TResult Function(String myError) laodingFailure,
  }) {
    return loadingSuccess(attendanceList);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<AttendanceModel> attendanceList)? loadingSuccess,
    TResult? Function(String myError)? laodingFailure,
  }) {
    return loadingSuccess?.call(attendanceList);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<AttendanceModel> attendanceList)? loadingSuccess,
    TResult Function(String myError)? laodingFailure,
    required TResult orElse(),
  }) {
    if (loadingSuccess != null) {
      return loadingSuccess(attendanceList);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_LoginSuccess value) loadingSuccess,
    required TResult Function(_LoginFailure value) laodingFailure,
  }) {
    return loadingSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_LoginSuccess value)? loadingSuccess,
    TResult? Function(_LoginFailure value)? laodingFailure,
  }) {
    return loadingSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_LoginSuccess value)? loadingSuccess,
    TResult Function(_LoginFailure value)? laodingFailure,
    required TResult orElse(),
  }) {
    if (loadingSuccess != null) {
      return loadingSuccess(this);
    }
    return orElse();
  }
}

abstract class _LoginSuccess implements AttendanceState {
  const factory _LoginSuccess(final List<AttendanceModel> attendanceList) =
      _$LoginSuccessImpl;

  List<AttendanceModel> get attendanceList;
  @JsonKey(ignore: true)
  _$$LoginSuccessImplCopyWith<_$LoginSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LoginFailureImplCopyWith<$Res> {
  factory _$$LoginFailureImplCopyWith(
          _$LoginFailureImpl value, $Res Function(_$LoginFailureImpl) then) =
      __$$LoginFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String myError});
}

/// @nodoc
class __$$LoginFailureImplCopyWithImpl<$Res>
    extends _$AttendanceStateCopyWithImpl<$Res, _$LoginFailureImpl>
    implements _$$LoginFailureImplCopyWith<$Res> {
  __$$LoginFailureImplCopyWithImpl(
      _$LoginFailureImpl _value, $Res Function(_$LoginFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? myError = null,
  }) {
    return _then(_$LoginFailureImpl(
      null == myError
          ? _value.myError
          : myError // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$LoginFailureImpl implements _LoginFailure {
  const _$LoginFailureImpl(this.myError);

  @override
  final String myError;

  @override
  String toString() {
    return 'AttendanceState.laodingFailure(myError: $myError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginFailureImpl &&
            (identical(other.myError, myError) || other.myError == myError));
  }

  @override
  int get hashCode => Object.hash(runtimeType, myError);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginFailureImplCopyWith<_$LoginFailureImpl> get copyWith =>
      __$$LoginFailureImplCopyWithImpl<_$LoginFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<AttendanceModel> attendanceList)
        loadingSuccess,
    required TResult Function(String myError) laodingFailure,
  }) {
    return laodingFailure(myError);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<AttendanceModel> attendanceList)? loadingSuccess,
    TResult? Function(String myError)? laodingFailure,
  }) {
    return laodingFailure?.call(myError);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<AttendanceModel> attendanceList)? loadingSuccess,
    TResult Function(String myError)? laodingFailure,
    required TResult orElse(),
  }) {
    if (laodingFailure != null) {
      return laodingFailure(myError);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_LoginSuccess value) loadingSuccess,
    required TResult Function(_LoginFailure value) laodingFailure,
  }) {
    return laodingFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_LoginSuccess value)? loadingSuccess,
    TResult? Function(_LoginFailure value)? laodingFailure,
  }) {
    return laodingFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_LoginSuccess value)? loadingSuccess,
    TResult Function(_LoginFailure value)? laodingFailure,
    required TResult orElse(),
  }) {
    if (laodingFailure != null) {
      return laodingFailure(this);
    }
    return orElse();
  }
}

abstract class _LoginFailure implements AttendanceState {
  const factory _LoginFailure(final String myError) = _$LoginFailureImpl;

  String get myError;
  @JsonKey(ignore: true)
  _$$LoginFailureImplCopyWith<_$LoginFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
