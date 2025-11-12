import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_data_view_provider.g.dart';

class HealthDataViewState {
  const HealthDataViewState({
    this.selectedFilter = 'all',
    this.selectedTag = '全部标签',
    this.searchKeyword = '',
    this.isListView = true,
  });

  final String selectedFilter;
  final String selectedTag;
  final String searchKeyword;
  final bool isListView;

  HealthDataViewState copyWith({
    String? selectedFilter,
    String? selectedTag,
    String? searchKeyword,
    bool? isListView,
  }) {
    return HealthDataViewState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedTag: selectedTag ?? this.selectedTag,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      isListView: isListView ?? this.isListView,
    );
  }
}

@riverpod
class HealthDataView extends _$HealthDataView {
  @override
  HealthDataViewState build() => const HealthDataViewState();

  void selectFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void selectTag(String tag) {
    state = state.copyWith(selectedTag: tag);
  }

  void setSearchKeyword(String keyword) {
    state = state.copyWith(searchKeyword: keyword);
  }

  void toggleViewMode() {
    state = state.copyWith(isListView: !state.isListView);
  }
}
