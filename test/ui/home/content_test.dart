import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/src/data/geocoding_repository.dart';
import 'package:weather_app/src/ui/home/content.dart';
import 'package:weather_app/src/ui/home/cubit.dart';

void main() {
  testWidgets('When state is empty Then hint text is displayed',
      (tester) async {
    await tester.pumpWidget(
      _createApp(
        const EmptyState(),
      ),
    );

    expect(find.text('Enter a city name to search.'), findsOneWidget);
  });

  testWidgets('When loading Then progress indicator is displayed',
      (tester) async {
    await tester.pumpWidget(
      _createApp(
        const EmptyState(isLoading: true),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('When not loading Then progress indicator is not displayed',
      (tester) async {
    await tester.pumpWidget(
      _createApp(
        const EmptyState(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets(
      'When state is loaded with no items Then no results text is displayed',
      (tester) async {
    await tester.pumpWidget(
      _createApp(const LoadedState(isLoading: false, query: '', items: [])),
    );

    expect(find.text('No results found.'), findsOneWidget);
  });

  testWidgets('When state is loaded with some items Then items are displayed',
      (tester) async {
    await tester.pumpWidget(
      _createApp(const LoadedState(isLoading: false, query: '', items: _items)),
    );

    expect(find.text('Berlin, DE'), findsOneWidget);
    expect(find.text('Berlin, New Hampshire, US'), findsOneWidget);
  });

  testWidgets('When state is error Then retry button displayed',
      (tester) async {
    await tester.pumpWidget(
      _createApp(const ErrorState(isLoading: false, query: '')),
    );

    expect(find.text('Retry'), findsOneWidget);
  });
}

MaterialApp _createApp(HomeState state) => MaterialApp(
      home: BlocProvider<HomeCubit>(
        create: (_) => _FakeHomeCubit(state),
        child: const HomeContent(),
      ),
    );

const _items = [
  (name: 'Berlin, DE', lat: 52.5170365, lon: 13.3888599),
  (name: 'Berlin, New Hampshire, US', lat: 44.4688795, lon: -71.1836547),
];

class _FakeHomeCubit extends Cubit<HomeState> implements HomeCubit {
  int onItemPressedInvocationCount = 0;
  int onQueryChangedInvocationCount = 0;
  int onRetryInvocationCount = 0;

  _FakeHomeCubit(super.initialState);

  @override
  void onItemPressed(NamedLocation item) {
    onItemPressedInvocationCount++;
  }

  @override
  void onQueryChanged(String query) {
    onQueryChangedInvocationCount++;
  }

  @override
  void onRetry() {
    onRetryInvocationCount++;
  }
}
