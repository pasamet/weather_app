// ignore_for_file: prefer_relative_imports

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/src/data/geocoding_repository.dart';

@immutable
sealed class HomeState {
  final bool isLoading;
  final String query;

  const HomeState({required this.isLoading, required this.query});

  HomeState copyWith({String? query, bool? isLoading});
}

class EmptyState extends HomeState {
  const EmptyState({super.query = '', super.isLoading = false});
  @override
  EmptyState copyWith({String? query, bool? isLoading}) => EmptyState(
        query: query ?? this.query,
        isLoading: isLoading ?? this.isLoading,
      );
}

class LoadedState extends HomeState {
  final List<NamedLocation> items;

  const LoadedState({
    required super.isLoading,
    required super.query,
    required this.items,
  });

  @override
  LoadedState copyWith({String? query, bool? isLoading}) => LoadedState(
        query: query ?? this.query,
        isLoading: isLoading ?? this.isLoading,
        items: items,
      );
}

class ErrorState extends HomeState {
  const ErrorState({required super.isLoading, required super.query});
  @override
  ErrorState copyWith({String? query, bool? isLoading}) => ErrorState(
        query: query ?? this.query,
        isLoading: isLoading ?? this.isLoading,
      );
}

abstract class HomeActions {
  void navigateToWeather(NamedLocation location);
}

class HomeCubit extends Cubit<HomeState> {
  final GeocodingRepository _repository;
  final HomeActions _actions;
  final _Debounce _debounce;

  HomeCubit({
    required GeocodingRepository repository,
    required HomeActions actions,
    @visibleForTesting Duration debounceDelay = const Duration(seconds: 1),
  })  : _repository = repository,
        _actions = actions,
        _debounce = _Debounce(debounceDelay),
        super(const EmptyState());

  @override
  Future<void> close() {
    _debounce.cancel();
    return super.close();
  }

  void onQueryChanged(String query) {
    if (query == state.query) {
      return;
    }
    if (query.isEmpty) {
      emit(const EmptyState());
      return;
    }
    emit(state.copyWith(query: query, isLoading: true));
    _debounce(() => _search(query));
  }

  void onRetry() {
    if (state is ErrorState && !state.isLoading) {
      _debounce.cancel();
      emit(state.copyWith(isLoading: true));
      _search(state.query);
    }
  }

  void onItemPressed(NamedLocation item) {
    if (state case LoadedState(:var items) when items.contains(item)) {
      _actions.navigateToWeather(item);
    }
  }

  Future<void> _search(String query) async {
    if (query != state.query) {
      return;
    }
    List<NamedLocation> items;
    try {
      items = await _repository.search(query);
    } catch (e, s) {
      debugPrint('$e\n$s');
      if (query == state.query) {
        emit(ErrorState(isLoading: false, query: query));
      }
      return;
    }
    if (query == state.query) {
      emit(LoadedState(isLoading: false, query: query, items: items));
    }
  }
}

class _Debounce {
  final Duration delay;
  Timer? _timer;

  _Debounce(this.delay);

  void call(void Function() callback) {
    cancel();
    _timer = Timer(delay, callback);
  }

  void cancel() => _timer?.cancel();
}
