// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'students_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$StudentsState {
  List<StudentModel> get students => throw _privateConstructorUsedError;
  List<StudentAttModel> get attlist => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            List<StudentModel> students, List<StudentAttModel> attlist)
        initial,
    required TResult Function(
            List<StudentModel> students, List<StudentAttModel> attlist)
        loading,
    required TResult Function(List<StudentModel> students,
            List<StudentAttModel> attlist, List<Remark> remarks)
        success,
    required TResult Function(String error, List<StudentModel> students,
            List<StudentAttModel> attlist)
        failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            List<StudentModel> students, List<StudentAttModel> attlist)?
        initial,
    TResult? Function(
            List<StudentModel> students, List<StudentAttModel> attlist)?
        loading,
    TResult? Function(List<StudentModel> students,
            List<StudentAttModel> attlist, List<Remark> remarks)?
        success,
    TResult? Function(String error, List<StudentModel> students,
            List<StudentAttModel> attlist)?
        failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            List<StudentModel> students, List<StudentAttModel> attlist)?
        initial,
    TResult Function(
            List<StudentModel> students, List<StudentAttModel> attlist)?
        loading,
    TResult Function(List<StudentModel> students, List<StudentAttModel> attlist,
            List<Remark> remarks)?
        success,
    TResult Function(String error, List<StudentModel> students,
            List<StudentAttModel> attlist)?
        failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $StudentsStateCopyWith<StudentsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentsStateCopyWith<$Res> {
  factory $StudentsStateCopyWith(
          StudentsState value, $Res Function(StudentsState) then) =
      _$StudentsStateCopyWithImpl<$Res, StudentsState>;
  @useResult
  $Res call({List<StudentModel> students, List<StudentAttModel> attlist});
}

/// @nodoc
class _$StudentsStateCopyWithImpl<$Res, $Val extends StudentsState>
    implements $StudentsStateCopyWith<$Res> {
  _$StudentsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? students = null,
    Object? attlist = null,
  }) {
    return _then(_value.copyWith(
      students: null == students
          ? _value.students
          : students // ignore: cast_nullable_to_non_nullable
              as List<StudentModel>,
      attlist: null == attlist
          ? _value.attlist
          : attlist // ignore: cast_nullable_to_non_nullable
              as List<StudentAttModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res>
    implements $StudentsStateCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<StudentModel> students, List<StudentAttModel> attlist});
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$StudentsStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? students = null,
    Object? attlist = null,
  }) {
    return _then(_$InitialImpl(
      students: null == students
          ? _value._students
          : students // ignore: cast_nullable_to_non_nullable
              as List<StudentModel>,
      attlist: null == attlist
          ? _value._attlist
          : attlist // ignore: cast_nullable_to_non_nullable
              as List<StudentAttModel>,
    ));
  }
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl(
      {final List<StudentModel> students = const [],
      final List<StudentAttModel> attlist = const []})
      : _students = students,
        _attlist = attlist;

  final List<StudentModel> _students;
  @override
  @JsonKey()
  List<StudentModel> get students {
    if (_students is EqualUnmodifiableListView) return _students;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_students);
  }

  final List<StudentAttModel> _attlist;
  @override
  @JsonKey()
  List<StudentAttModel> get attlist {
    if (_attlist is EqualUnmodifiableListView) return _attlist;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attlist);
  }

  @override
  String toString() {
    return 'StudentsState.initial(students: $students, attlist: $attlist)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InitialImpl &&
            const DeepCollectionEquality().equals(other._students, _students) &&
            const DeepCollectionEquality().equals(other._attlist, _attlist));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_students),
      const DeepCollectionEquality().hash(_attlist));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InitialImplCopyWith<_$InitialImpl> get copyWith =>
      __$$InitialImplCopyWithImpl<_$InitialImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            List<StudentModel> students, List<StudentAttModel> attlist)
        initial,
    required TResult Function(
            List<StudentModel> students, List<StudentAttModel> attlist)
        loading,
    required TResult Function(List<StudentModel> students,
            List<StudentAttModel> attlist, List<Remark> remarks)
        success,
    required TResult Function(String error, List<StudentModel> students,
            List<StudentAttModel> attlist)
        failure,
  }) {
    return initial(students, attlist);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            List<StudentModel> students, List<StudentAttModel> attlist)?
        initial,
    TResult? Function(
            List<StudentModel> students, List<StudentAttModel> attlist)?
        loading,
    TResult? Function(List<StudentModel> students,
            List<StudentAttModel> attlist, List<Remark> remarks)?
        success,
    TResult? Function(String error, List<StudentModel> students,
            List<StudentAttModel> attlist)?
        failure,
  }) {
    return initial?.call(students, attlist);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            List<StudentModel> students, List<StudentAttModel> attlist)?
        initial,
    TResult Function(
            List<StudentModel> students, List<StudentAttModel> attlist)?
        loading,
    TResult Function(List<StudentModel> students, List<StudentAttModel> attlist,
            List<Remark> remarks)?
        success,
    TResult Function(String error, List<StudentModel> students,
            List<StudentAttModel> attlist)?
        failure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(students, attlist);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements StudentsState {
  const factory _Initial(
      {final List<StudentModel> students,
      final List<StudentAttModel> attlist}) = _$InitialImpl;

  @override
  List<StudentModel> get students;
  @override
  List<StudentAttModel> get attlist;
  @override
  @JsonKey(ignore: true)
  _$$InitialImplCopyWith<_$InitialImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res>
    implements $StudentsStateCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<StudentModel> students, List<StudentAttModel> attlist});
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$StudentsStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? students = null,
    Object? attlist = null,
  }) {
    return _then(_$LoadingImpl(
      students: null == students
          ? _value._students
          : students // ignore: cast_nullable_to_non_nullable
              as List<StudentModel>,
      attlist: null == attlist
          ? _value._attlist
          : attlist // ignore: cast_nullable_to_non_nullable
              as List<StudentAttModel>,
    ));
  }
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl(
      {required final List<StudentModel> students,
      required final List<StudentAttModel> attlist})
      : _students = students,
        _attlist = attlist;

  final List<StudentModel> _students;
  @override
  List<StudentModel> get students {
    if (_students is EqualUnmodifiableListView) return _students;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_students);
  }

  final List<StudentAttModel> _attlist;
  @override
  List<StudentAttModel> get attlist {
    if (_attlist is EqualUnmodifiableListView) return _attlist;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attlist);
  }

  @override
  String toString() {
    return 'StudentsState.loading(students: $students, attlist: $attlist)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadingImpl &&
            const DeepCollectionEquality().equals(other._students, _students) &&
            const DeepCollectionEquality().equals(other._attlist, _attlist));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_students),
      const DeepCollectionEquality().hash(_attlist));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadingImplCopyWith<_$LoadingImpl> get copyWith =>
      __$$LoadingImplCopyWithImpl<_$LoadingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            List<StudentModel> students, List<StudentAttModel> attlist)
        initial,
    required TResult Function(
            List<StudentModel> students, List<StudentAttModel> attlist)
        loading,
    required TResult Function(List<StudentModel> students,
            List<StudentAttModel> attlist, List<Remark> remarks)
        success,
    required TResult Function(String error, List<StudentModel> students,
            List<StudentAttModel> attlist)
        failure,
  }) {
    return loading(students, attlist);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            List<StudentModel> students, List<StudentAttModel> attlist)?
        initial,
    TResult? Function(
            List<StudentModel> students, List<StudentAttModel> attlist)?
        loading,
    TResult? Function(List<StudentModel> students,
            List<StudentAttModel> attlist, List<Remark> remarks)?
        success,
    TResult? Function(String error, List<StudentModel> students,
            List<StudentAttModel> attlist)?
        failure,
  }) {
    return loading?.call(students, attlist);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            List<StudentModel> students, List<StudentAttModel> attlist)?
        initial,
    TResult Function(
            List<StudentModel> students, List<StudentAttModel> attlist)?
        loading,
    TResult Function(List<StudentModel> students, List<StudentAttModel> attlist,
            List<Remark> remarks)?
        success,
    TResult Function(String error, List<StudentModel> students,
            List<StudentAttModel> attlist)?
        failure,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(students, attlist);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements StudentsState {
  const factory _Loading(
      {required final List<StudentModel> students,
      required final List<StudentAttModel> attlist}) = _$LoadingImpl;

  @override
  List<StudentModel> get students;
  @override
  List<StudentAttModel> get attlist;
  @override
  @JsonKey(ignore: true)
  _$$LoadingImplCopyWith<_$LoadingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SuccessImplCopyWith<$Res>
    implements $StudentsStateCopyWith<$Res> {
  factory _$$SuccessImplCopyWith(
          _$SuccessImpl value, $Res Function(_$SuccessImpl) then) =
      __$$SuccessImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<StudentModel> students,
      List<StudentAttModel> attlist,
      List<Remark> remarks});
}

/// @nodoc
class __$$SuccessImplCopyWithImpl<$Res>
    extends _$StudentsStateCopyWithImpl<$Res, _$SuccessImpl>
    implements _$$SuccessImplCopyWith<$Res> {
  __$$SuccessImplCopyWithImpl(
      _$SuccessImpl _value, $Res Function(_$SuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? students = null,
    Object? attlist = null,
    Object? remarks = null,
  }) {
    return _then(_$SuccessImpl(
      students: null == students
          ? _value._students
          : students // ignore: cast_nullable_to_non_nullable
              as List<StudentModel>,
      attlist: null == attlist
          ? _value._attlist
          : attlist // ignore: cast_nullable_to_non_nullable
              as List<StudentAttModel>,
      remarks: null == remarks
          ? _value._remarks
          : remarks // ignore: cast_nullable_to_non_nullable
              as List<Remark>,
    ));
  }
}

/// @nodoc

class _$SuccessImpl implements _Success {
  const _$SuccessImpl(
      {required final List<StudentModel> students,
      required final List<StudentAttModel> attlist,
      required final List<Remark> remarks})
      : _students = students,
        _attlist = attlist,
        _remarks = remarks;

  final List<StudentModel> _students;
  @override
  List<StudentModel> get students {
    if (_students is EqualUnmodifiableListView) return _students;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_students);
  }

  final List<StudentAttModel> _attlist;
  @override
  List<StudentAttModel> get attlist {
    if (_attlist is EqualUnmodifiableListView) return _attlist;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attlist);
  }

  final List<Remark> _remarks;
  @override
  List<Remark> get remarks {
    if (_remarks is EqualUnmodifiableListView) return _remarks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_remarks);
  }

  @override
  String toString() {
    return 'StudentsState.success(students: $students, attlist: $attlist, remarks: $remarks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuccessImpl &&
            const DeepCollectionEquality().equals(other._students, _students) &&
            const DeepCollectionEquality().equals(other._attlist, _attlist) &&
            const DeepCollectionEquality().equals(other._remarks, _remarks));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_students),
      const DeepCollectionEquality().hash(_attlist),
      const DeepCollectionEquality().hash(_remarks));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      __$$SuccessImplCopyWithImpl<_$SuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            List<StudentModel> students, List<StudentAttModel> attlist)
        initial,
    required TResult Function(
            List<StudentModel> students, List<StudentAttModel> attlist)
        loading,
    required TResult Function(List<StudentModel> students,
            List<StudentAttModel> attlist, List<Remark> remarks)
        success,
    required TResult Function(String error, List<StudentModel> students,
            List<StudentAttModel> attlist)
        failure,
  }) {
    return success(students, attlist, remarks);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            List<StudentModel> students, List<StudentAttModel> attlist)?
        initial,
    TResult? Function(
            List<StudentModel> students, List<StudentAttModel> attlist)?
        loading,
    TResult? Function(List<StudentModel> students,
            List<StudentAttModel> attlist, List<Remark> remarks)?
        success,
    TResult? Function(String error, List<StudentModel> students,
            List<StudentAttModel> attlist)?
        failure,
  }) {
    return success?.call(students, attlist, remarks);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            List<StudentModel> students, List<StudentAttModel> attlist)?
        initial,
    TResult Function(
            List<StudentModel> students, List<StudentAttModel> attlist)?
        loading,
    TResult Function(List<StudentModel> students, List<StudentAttModel> attlist,
            List<Remark> remarks)?
        success,
    TResult Function(String error, List<StudentModel> students,
            List<StudentAttModel> attlist)?
        failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(students, attlist, remarks);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _Success implements StudentsState {
  const factory _Success(
      {required final List<StudentModel> students,
      required final List<StudentAttModel> attlist,
      required final List<Remark> remarks}) = _$SuccessImpl;

  @override
  List<StudentModel> get students;
  @override
  List<StudentAttModel> get attlist;
  List<Remark> get remarks;
  @override
  @JsonKey(ignore: true)
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FailureImplCopyWith<$Res>
    implements $StudentsStateCopyWith<$Res> {
  factory _$$FailureImplCopyWith(
          _$FailureImpl value, $Res Function(_$FailureImpl) then) =
      __$$FailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String error,
      List<StudentModel> students,
      List<StudentAttModel> attlist});
}

/// @nodoc
class __$$FailureImplCopyWithImpl<$Res>
    extends _$StudentsStateCopyWithImpl<$Res, _$FailureImpl>
    implements _$$FailureImplCopyWith<$Res> {
  __$$FailureImplCopyWithImpl(
      _$FailureImpl _value, $Res Function(_$FailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
    Object? students = null,
    Object? attlist = null,
  }) {
    return _then(_$FailureImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
      students: null == students
          ? _value._students
          : students // ignore: cast_nullable_to_non_nullable
              as List<StudentModel>,
      attlist: null == attlist
          ? _value._attlist
          : attlist // ignore: cast_nullable_to_non_nullable
              as List<StudentAttModel>,
    ));
  }
}

/// @nodoc

class _$FailureImpl implements _Failure {
  const _$FailureImpl(this.error,
      {required final List<StudentModel> students,
      required final List<StudentAttModel> attlist})
      : _students = students,
        _attlist = attlist;

  @override
  final String error;
  final List<StudentModel> _students;
  @override
  List<StudentModel> get students {
    if (_students is EqualUnmodifiableListView) return _students;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_students);
  }

  final List<StudentAttModel> _attlist;
  @override
  List<StudentAttModel> get attlist {
    if (_attlist is EqualUnmodifiableListView) return _attlist;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attlist);
  }

  @override
  String toString() {
    return 'StudentsState.failure(error: $error, students: $students, attlist: $attlist)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FailureImpl &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other._students, _students) &&
            const DeepCollectionEquality().equals(other._attlist, _attlist));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      error,
      const DeepCollectionEquality().hash(_students),
      const DeepCollectionEquality().hash(_attlist));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FailureImplCopyWith<_$FailureImpl> get copyWith =>
      __$$FailureImplCopyWithImpl<_$FailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            List<StudentModel> students, List<StudentAttModel> attlist)
        initial,
    required TResult Function(
            List<StudentModel> students, List<StudentAttModel> attlist)
        loading,
    required TResult Function(List<StudentModel> students,
            List<StudentAttModel> attlist, List<Remark> remarks)
        success,
    required TResult Function(String error, List<StudentModel> students,
            List<StudentAttModel> attlist)
        failure,
  }) {
    return failure(error, students, attlist);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            List<StudentModel> students, List<StudentAttModel> attlist)?
        initial,
    TResult? Function(
            List<StudentModel> students, List<StudentAttModel> attlist)?
        loading,
    TResult? Function(List<StudentModel> students,
            List<StudentAttModel> attlist, List<Remark> remarks)?
        success,
    TResult? Function(String error, List<StudentModel> students,
            List<StudentAttModel> attlist)?
        failure,
  }) {
    return failure?.call(error, students, attlist);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            List<StudentModel> students, List<StudentAttModel> attlist)?
        initial,
    TResult Function(
            List<StudentModel> students, List<StudentAttModel> attlist)?
        loading,
    TResult Function(List<StudentModel> students, List<StudentAttModel> attlist,
            List<Remark> remarks)?
        success,
    TResult Function(String error, List<StudentModel> students,
            List<StudentAttModel> attlist)?
        failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(error, students, attlist);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class _Failure implements StudentsState {
  const factory _Failure(final String error,
      {required final List<StudentModel> students,
      required final List<StudentAttModel> attlist}) = _$FailureImpl;

  String get error;
  @override
  List<StudentModel> get students;
  @override
  List<StudentAttModel> get attlist;
  @override
  @JsonKey(ignore: true)
  _$$FailureImplCopyWith<_$FailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
