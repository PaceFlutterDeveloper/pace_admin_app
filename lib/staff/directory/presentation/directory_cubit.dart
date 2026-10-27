import 'package:admin_app/staff/directory/domain/directory_repository.dart';
import 'package:admin_app/staff/directory/domain/staff_member.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DirectoryState {
  const DirectoryState({
    this.items = const [],
    this.total = 0,
    this.loading = true,
    this.loadingMore = false,
    this.hasMore = false,
    this.error,
    this.query = '',
  });

  final List<StaffMember> items;
  final int total;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final String? error;
  final String query;
}

/// Search and endless scroll over the staff directory.
class DirectoryCubit extends Cubit<DirectoryState> {
  DirectoryCubit(this._repository) : super(const DirectoryState());

  final DirectoryRepository _repository;
  int _page = 0;

  /// Bumped for each new search so a slow earlier answer is ignored.
  int _generation = 0;

  Future<void> search(String query) async {
    final generation = ++_generation;
    _page = 0;
    emit(DirectoryState(query: query));
    try {
      final result = await _repository.list(search: query, page: 0);
      if (generation != _generation || isClosed) return;
      emit(
        DirectoryState(
          query: query,
          loading: false,
          items: result.items,
          hasMore: result.hasMore,
          total: result.total,
        ),
      );
    } catch (error) {
      if (generation != _generation || isClosed) return;
      emit(
        DirectoryState(
          query: query,
          loading: false,
          error: staffErrorMessage(error),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current.loading || current.loadingMore || !current.hasMore) return;
    final generation = _generation;
    emit(
      DirectoryState(
        query: current.query,
        items: current.items,
        total: current.total,
        loading: false,
        loadingMore: true,
        hasMore: true,
      ),
    );
    try {
      final result = await _repository.list(
        search: current.query,
        page: _page + 1,
      );
      if (generation != _generation || isClosed) return;
      _page++;
      emit(
        DirectoryState(
          query: current.query,
          loading: false,
          items: [...current.items, ...result.items],
          hasMore: result.hasMore,
          total: result.total == 0 ? current.total : result.total,
        ),
      );
    } catch (_) {
      if (generation != _generation || isClosed) return;
      emit(
        DirectoryState(
          query: current.query,
          loading: false,
          items: current.items,
          total: current.total,
          hasMore: true,
        ),
      );
    }
  }
}
