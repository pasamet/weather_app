import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/src/data/geocoding_repository.dart';
import 'package:weather_app/src/data/weather_api.dart';

void main() {
  test('When search called Then returns matching results', () async {
    var api = _FakeWeatherApi();
    var sut = GeocodingRepository(api: api);
    var query = 'berlin';

    var actual = await sut.search(query);

    expect(api.lastDirectGeocodingQuery, query);
    expect(api.directGeocodingInvocationCount, 1);
    expect(actual, [
      (name: 'Berlin, DE', lat: 52.5170365, lon: 13.3888599),
      (name: 'Berlin, New Hampshire, US', lat: 44.4688795, lon: -71.1836547),
    ]);
  });
}

class _FakeWeatherApi implements WeatherApi {
  int directGeocodingInvocationCount = 0;
  String? lastDirectGeocodingQuery;

  @override
  Future<List<Location>> directGeocoding(String query, [int limit = 20]) async {
    directGeocodingInvocationCount++;
    lastDirectGeocodingQuery = query;
    return [
      Location(
        name: 'Berlin',
        localNames: {},
        lat: 52.5170365,
        lon: 13.3888599,
        country: 'DE',
      ),
      Location(
        name: 'Berlin',
        localNames: {},
        lat: 44.4688795,
        lon: -71.1836547,
        country: 'US',
        state: 'New Hampshire',
      ),
    ];
  }
}
