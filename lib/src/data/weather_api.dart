import 'dart:async';

import 'package:json_annotation/json_annotation.dart';

import 'json_client.dart';

part 'weather_api.g.dart';

/// [Open weather API](https://openweathermap.org/api) client
class WeatherApi {
  final JsonClient _client;
  final Uri _baseUri;
  final String _apiKey;

  WeatherApi({
    required JsonClient client,
    required Uri baseUri,
    required String apiKey,
  })  : _client = client,
        _baseUri = baseUri,
        _apiKey = apiKey;

  // http://api.openweathermap.org/geo/1.0/direct?q={city name},{state code},{country code}&limit={limit}&appid={API key}
  Future<List<Location>> directGeocoding(String query, [int limit = 20]) =>
      _client.getJsonObjectList(
        _resolveUri(
          ['geo', '1.0', 'direct'],
          {'q': query, 'limit': '$limit'},
        ),
        Location.fromJson,
      );

  Uri _resolveUri(
    Iterable<String> pathSegments,
    Map<String, String> queryParameters,
  ) =>
      _baseUri.resolveUri(
        Uri(
          pathSegments: pathSegments,
          queryParameters: {...queryParameters, 'appid': _apiKey},
        ),
      );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Location {
  final String name;
  final Map<String, String>? localNames;
  final double lat;
  final double lon;
  final String country;
  final String? state;

  Location({
    required this.name,
    required this.localNames,
    required this.lat,
    required this.lon,
    required this.country,
    this.state,
  });

  factory Location.fromJson(Map<String, Object?> json) =>
      _$LocationFromJson(json);
  Map<String, Object?> toJson() => _$LocationToJson(this);
}
