// ignore_for_file: require_trailing_commas

import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/src/data/geocoding_repository.dart';
import 'package:weather_app/src/ui/home/cubit.dart';

void main() {
  late _FakeRepository repository;
  late _FakeActions actions;
  late HomeCubit sut;

  setUp(() {
    repository = _FakeRepository();
    actions = _FakeActions();
    sut = HomeCubit(
        repository: repository,
        actions: actions,
        debounceDelay: const Duration(milliseconds: 10));
  });

  test('When query typed Then waits before requesting results', () async {
    sut.onQueryChanged('b');
    await _waitMs(1);
    sut.onQueryChanged('ber');
    await _waitMs(1);
    sut.onQueryChanged('berlin');
    await _waitMs(11);

    expect(repository.searchInvocationCount, 1);
    expect(repository.lastSearchQuery, 'berlin');
    expect(
        sut.state,
        isA<LoadedState>().having(
          (state) => state.items,
          'Items',
          _items,
        ));
    expect(sut.state.isLoading, false);
  });

  test(
      'Given request fails When retry tapped Then requests results immediately',
      () async {
    repository.searchWillFail = true;
    sut.onQueryChanged('berlin');
    await _waitMs(11);

    sut.onRetry();

    expect(repository.searchInvocationCount, 2);
    expect(repository.lastSearchQuery, 'berlin');
    expect(sut.state, isA<ErrorState>());
  });

  test('Given loaded When an item tapped Then navigates to the weather screen',
      () async {
    sut.onQueryChanged('berlin');
    await _waitMs(11);

    sut.onItemPressed(_berlinDe);

    expect(actions.navigateToWeatherInvocationCount, 1);
    expect(actions.lastNavigateToWeatherLocation, _berlinDe);
  });
}

Future<void> _waitMs(int milliseconds) =>
    Future<void>.delayed(Duration(milliseconds: milliseconds));

var _berlinDe = (name: 'Berlin, DE', lat: 52.5170365, lon: 13.3888599);

var _items = [
  _berlinDe,
  (name: 'Berlin, New Hampshire, US', lat: 44.4688795, lon: -71.1836547),
];

class _FakeRepository implements GeocodingRepository {
  bool searchWillFail = false;
  int searchInvocationCount = 0;
  String? lastSearchQuery;

  @override
  Future<List<NamedLocation>> search(String query) async {
    searchInvocationCount++;
    lastSearchQuery = query;
    if (searchWillFail) {
      throw Exception();
    }
    return _items;
  }
}

class _FakeActions implements HomeActions {
  int navigateToWeatherInvocationCount = 0;
  NamedLocation? lastNavigateToWeatherLocation;

  @override
  void navigateToWeather(NamedLocation location) {
    navigateToWeatherInvocationCount++;
    lastNavigateToWeatherLocation = location;
  }
}
