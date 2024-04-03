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

  // http://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API key}
  Future<WeatherData> forecast({
    required double lat,
    required double lon,
  }) =>
      _client.getJsonObject(
        _resolveUri(
          ['data', '2.5', 'forecast'],
          {'lat': '$lat', 'lon': '$lon'},
        ),
        WeatherData.fromJson,
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

@JsonSerializable(fieldRename: FieldRename.snake)
class WeatherData {
  final List<Prediction> list;

  WeatherData({required this.list});

  factory WeatherData.fromJson(Map<String, Object?> json) =>
      _$WeatherDataFromJson(json);
  Map<String, Object?> toJson() => _$WeatherDataToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Prediction {
  final int dt;
  final Main main;
  final List<Weather> weather;
  final Wind wind;

  factory Prediction.fromJson(Map<String, Object?> json) =>
      _$PredictionFromJson(json);

  Prediction({
    required this.dt,
    required this.main,
    required this.weather,
    required this.wind,
  });
  Map<String, Object?> toJson() => _$PredictionToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Main {
  final double temp;
  final double tempMin;
  final double tempMax;
  final double pressure;
  final double humidity;

  Main({
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
  });

  factory Main.fromJson(Map<String, Object?> json) => _$MainFromJson(json);
  Map<String, Object?> toJson() => _$MainToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Weather {
  final int id;
  final String main;
  final String description;
  final String icon;

  Weather({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, Object?> json) =>
      _$WeatherFromJson(json);
  Map<String, Object?> toJson() => _$WeatherToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Wind {
  final double speed;

  factory Wind.fromJson(Map<String, Object?> json) => _$WindFromJson(json);

  Wind({required this.speed});
  Map<String, Object?> toJson() => _$WindToJson(this);
}
