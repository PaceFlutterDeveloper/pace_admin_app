import 'package:admin_app/staff/shared/read_json.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class LoadState<T> {
  const LoadState();
}

class LoadInProgress<T> extends LoadState<T> {
  const LoadInProgress();
}

class LoadSuccess<T> extends LoadState<T> {
  const LoadSuccess(this.data);

  final T data;
}

class LoadFailure<T> extends LoadState<T> {
  const LoadFailure(this.message);

  final String message;
}

/// Loads one value for a screen. Pull to refresh calls [load] with
/// `quiet: true` so the list stays on screen while the new data arrives.
class LoadCubit<T> extends Cubit<LoadState<T>> {
  LoadCubit(this._loader) : super(const LoadInProgress());

  final Future<T> Function() _loader;

  T? get value => switch (state) {
    LoadSuccess<T>(:final data) => data,
    _ => null,
  };

  Future<void> load({bool quiet = false}) async {
    final keep = quiet && state is LoadSuccess<T>;
    if (!keep) emit(LoadInProgress<T>());
    try {
      final data = await _loader();
      if (!isClosed) emit(LoadSuccess<T>(data));
    } catch (error) {
      if (!keep && !isClosed) emit(LoadFailure<T>(staffErrorMessage(error)));
    }
  }
}
