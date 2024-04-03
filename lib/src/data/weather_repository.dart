import 'package:flutter/cupertino.dart';

import 'weather_api.dart';

const _oneMSinKmH = 3.6;
const _zeroCelsiusInKelvin = 273.15;

class WeatherRepository {
  final WeatherApi _api;

  WeatherRepository({required WeatherApi api}) : _api = api;

  Future<List<Forecast>> getDailyForecast({
    required double lat,
    required double lon,
  }) async {
    var result = await _api.forecast(lat: lat, lon: lon);
    assert(result.list.isNotEmpty);
    assert(result.list.every((element) => element.weather.isNotEmpty));
    return result.list
        .map(
          (daily) => Forecast(
            date: DateTime.fromMillisecondsSinceEpoch(daily.dt * 1000),
            min: Temperature(daily.main.tempMin),
            max: Temperature(daily.main.tempMax),
            temperature: Temperature(daily.main.temp),
            humidityPercent: daily.main.humidity,
            pressureHPa: daily.main.pressure,
            windSpeedKmH: daily.wind.speed * _oneMSinKmH,
            description: daily.weather.first.description,
            smallIconUri: Uri.parse(
              'https://openweathermap.org/img/wn/${daily.weather.first.icon}@2x.png',
            ),
            largeIconUri: Uri.parse(
              'https://openweathermap.org/img/wn/${daily.weather.first.icon}@4x.png',
            ),
          ),
        )
        .toList(growable: false);
  }
}

@immutable
class Forecast {
  final DateTime date;
  final Temperature min;
  final Temperature max;
  final Temperature temperature;
  final double humidityPercent;
  final double pressureHPa;
  final double windSpeedKmH;
  final String description;
  final Uri smallIconUri;
  final Uri largeIconUri;

  const Forecast({
    required this.date,
    required this.min,
    required this.max,
    required this.temperature,
    required this.humidityPercent,
    required this.pressureHPa,
    required this.windSpeedKmH,
    required this.description,
    required this.smallIconUri,
    required this.largeIconUri,
  });
}

@immutable
class Temperature {
  final double inKelvin;

  const Temperature(this.inKelvin);

  double get inCelsius => inKelvin - _zeroCelsiusInKelvin;
  double get inFahrenheit => inCelsius * 1.8 + 32.0;
}
