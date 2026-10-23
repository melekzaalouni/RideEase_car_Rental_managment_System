import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/models.dart';

class PagedState<T> {
  const PagedState({required this.items, required this.page, required this.last, this.loadingMore = false});
  final List<T> items;
  final int page;
  final bool last;
  final bool loadingMore;

  PagedState<T> copyWith({List<T>? items, int? page, bool? last, bool? loadingMore}) => PagedState(
        items: items ?? this.items,
        page: page ?? this.page,
        last: last ?? this.last,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

abstract class PagedNotifier<T> extends AsyncNotifier<PagedState<T>> {
  Future<PageData<T>> fetch(int page);

  @override
  Future<PagedState<T>> build() async {
    final r = await fetch(0); // called before any other await so watches are tracked
    return PagedState(items: r.content, page: 0, last: r.last);
  }

  Future<void> loadMore() async {
    final cur = state.valueOrNull;
    if (cur == null || cur.last || cur.loadingMore) return;
    state = AsyncData(cur.copyWith(loadingMore: true));
    try {
      final r = await fetch(cur.page + 1);
      state = AsyncData(PagedState(
        items: [...cur.items, ...r.content],
        page: cur.page + 1,
        last: r.last,
      ));
    } catch (_) {
      state = AsyncData(cur.copyWith(loadingMore: false));
    }
  }
}
