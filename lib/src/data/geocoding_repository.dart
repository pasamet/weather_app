// ignore_for_file: prefer_relative_imports

import 'package:weather_app/src/data/weather_api.dart';

class GeocodingRepository {
  final WeatherApi _api;

  GeocodingRepository({required WeatherApi api}) : _api = api;

  Future<List<NamedLocation>> search(String query) async {
    var result = await _api.directGeocoding(query);
    return result.map((e) {
      var state = e.state != null ? '${e.state}, ' : '';
      var name = '${e.name}, $state${e.country}';
      return (name: name, lat: e.lat, lon: e.lon);
    }).toList(growable: false);
  }
}

typedef NamedLocation = ({
  String name,
  double lat,
  double lon,
});
