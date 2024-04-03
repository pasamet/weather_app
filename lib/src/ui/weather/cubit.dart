import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/geocoding_repository.dart';
import '../../data/weather_repository.dart';

sealed class WeatherState {
  final String title;
  final TemperatureUnit temperatureUnit;

  WeatherState({required this.title, required this.temperatureUnit});
}

class LoadingState extends WeatherState {
  LoadingState({required super.title, required super.temperatureUnit});
}

class ErrorState extends WeatherState {
  ErrorState({required super.title, required super.temperatureUnit});
}

class LoadedState extends WeatherState {
  final int selectedDayIndex;
  final List<Day> days;
  final WeekDay selectedWeekDay;
  final Temperature temperature;
  final double humidityPercent;
  final double pressureHPa;
  final double windSpeedKmH;
  final String description;
  final Uri largeIconUri;

  LoadedState({
    required super.title,
    required super.temperatureUnit,
    required this.selectedDayIndex,
    required this.temperature,
    required this.days,
    required this.selectedWeekDay,
    required this.humidityPercent,
    required this.pressureHPa,
    required this.windSpeedKmH,
    required this.description,
    required this.largeIconUri,
  });
}

class Day {
  final WeekDay weekDay;
  final Uri smallIconUri;
  final Temperature minTemperature;
  final Temperature maxTemperature;

  Day({
    required this.weekDay,
    required this.smallIconUri,
    required this.minTemperature,
    required this.maxTemperature,
  });
}

enum WeekDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  static WeekDay from(DateTime dateTime) =>
      WeekDay.values[dateTime.weekday - 1];
}

enum TemperatureUnit {
  celsius,
  fahrenheit,
}

class WeatherCubit extends Cubit<WeatherState> {
  final WeatherRepository _repository;
  final NamedLocation _location;
  List<Forecast>? dailyForecast;

  WeatherCubit(WeatherRepository repository, NamedLocation location)
      : _repository = repository,
        _location = location,
        super(
          LoadingState(
            title: location.name,
            temperatureUnit: TemperatureUnit.celsius,
          ),
        ) {
    onRefresh();
  }

  Future<void> onRefresh() async {
    try {
      dailyForecast = await _repository.getDailyForecast(
        lat: _location.lat,
        lon: _location.lon,
      );
      _updateState();
    } catch (e, s) {
      debugPrint('$e\n$s');
      emit(
        ErrorState(
          title: state.title,
          temperatureUnit: state.temperatureUnit,
        ),
      );
    }
  }

  void _updateState({
    int? selectedDayIndex,
    TemperatureUnit? temperatureUnit,
  }) {
    var s = state;
    var forecasts = dailyForecast;
    if (forecasts != null) {
      assert(forecasts.isNotEmpty);
      selectedDayIndex ??=
          s is LoadedState && s.selectedDayIndex < forecasts.length
              ? s.selectedDayIndex
              : 0;

      var now = _splitDayAndTime(DateTime.now());
      var filteredForecasts = _filterByTimeOfTheDay(forecasts, now.timeOfDay)
          .toList(growable: false);

      var days = filteredForecasts
          .map(
            (d) => Day(
              weekDay: WeekDay.from(d.date),
              smallIconUri: d.smallIconUri,
              minTemperature: d.min,
              maxTemperature: d.max,
            ),
          )
          .toList(growable: false);

      var selectedDay = filteredForecasts[selectedDayIndex];

      emit(
        LoadedState(
          title: s.title,
          temperatureUnit: temperatureUnit ?? s.temperatureUnit,
          selectedDayIndex: selectedDayIndex,
          days: days,
          selectedWeekDay: WeekDay.from(selectedDay.date),
          temperature: selectedDay.temperature,
          humidityPercent: selectedDay.humidityPercent,
          pressureHPa: selectedDay.pressureHPa,
          windSpeedKmH: selectedDay.windSpeedKmH,
          description: selectedDay.description,
          largeIconUri: selectedDay.largeIconUri,
        ),
      );
    } else {
      if (s is ErrorState) {
        emit(
          ErrorState(
            title: s.title,
            temperatureUnit: temperatureUnit ?? s.temperatureUnit,
          ),
        );
      } else {
        emit(
          LoadingState(
            title: s.title,
            temperatureUnit: temperatureUnit ?? s.temperatureUnit,
          ),
        );
      }
    }
  }

  void onRetry() {
    if (state is! ErrorState) {
      return;
    }
    emit(
      LoadingState(title: state.title, temperatureUnit: state.temperatureUnit),
    );
    onRefresh();
  }

  void onDaySelected(int dayIndex) {
    var s = state;
    if (s is! LoadedState) {
      return;
    }
    if (dayIndex == s.selectedDayIndex) {
      return;
    }
    assert(dayIndex < s.days.length);
    assert(dayIndex >= 0);
    _updateState(selectedDayIndex: dayIndex);
  }

  void onUnitsChanged(TemperatureUnit unit) {
    if (state.temperatureUnit != unit) {
      _updateState(temperatureUnit: unit);
    }
  }
}

Iterable<Forecast> _filterByTimeOfTheDay(
  List<Forecast> forecasts,
  Duration timeOfTheDay,
) =>
    _groupByDayStart(forecasts)
        .values
        .map((value) => _findClosestByTimeOfDay(value, timeOfTheDay));

({DateTime day, Duration timeOfDay}) _splitDayAndTime(DateTime dateTime) {
  var day = _startOfTheDay(dateTime);
  var result = (
    day: day,
    timeOfDay: dateTime.difference(day),
  );
  assert(!result.timeOfDay.isNegative);
  return result;
}

DateTime _startOfTheDay(DateTime date) => date.toLocal().copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );

Map<DateTime, Iterable<_TimeOfDayAndForecast>> _groupByDayStart(
  List<Forecast> forecasts,
) {
  var result = <DateTime, List<_TimeOfDayAndForecast>>{};
  for (var forecast in forecasts) {
    var date = _splitDayAndTime(forecast.date);
    var value = (timeOfDay: date.timeOfDay, forecast: forecast);
    result.update(
      date.day,
      (list) => list..add(value),
      ifAbsent: () => [value],
    );
  }
  return result;
}

Forecast _findClosestByTimeOfDay(
  Iterable<_TimeOfDayAndForecast> list,
  Duration duration,
) =>
    list
        .map(
          (e) => (
            timeOfDay: (duration - e.timeOfDay).abs(),
            forecast: e.forecast,
          ),
        )
        .reduce(
          (min, element) => min.timeOfDay < element.timeOfDay ? min : element,
        )
        .forecast;

typedef _TimeOfDayAndForecast = ({Duration timeOfDay, Forecast forecast});
