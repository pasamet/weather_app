import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/weather_repository.dart';
import '../common/dimensions.dart';
import 'cubit.dart';

class WeatherContent extends StatelessWidget {
  const WeatherContent({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<WeatherCubit, WeatherState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text(state.title),
            actions: [
              _buildUnitSelection(context, state),
            ],
          ),
          body: switch (state) {
            LoadingState() => _buildLoading(),
            ErrorState() => _buildError(context),
            LoadedState() => _buildLoaded(context, state),
          },
        ),
      );

  Padding _buildUnitSelection(
    BuildContext context,
    WeatherState state,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SegmentedButton(
          segments: const [
            ButtonSegment(
              value: TemperatureUnit.celsius,
              label: Text('°C'),
            ),
            ButtonSegment(
              value: TemperatureUnit.fahrenheit,
              label: Text('°F'),
            ),
          ],
          selected: {state.temperatureUnit},
          onSelectionChanged: (selection) {
            if (selection.isNotEmpty) {
              context.read<WeatherCubit>().onUnitsChanged(selection.first);
            }
          },
        ),
      );

  Widget _buildLoading() => const Center(child: CircularProgressIndicator());

  Widget _buildError(BuildContext context) => SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline),
            gap16,
            const Text('Request failed.'),
            gap16,
            FilledButton(
              onPressed: () => context.read<WeatherCubit>().onRetry(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );

  Widget _buildLoaded(BuildContext context, LoadedState state) {
    var textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: containerInsets,
            child: Column(
              children: [
                Text(
                  state.selectedWeekDay.longText(),
                  style: textTheme.headlineMedium,
                ),
                gap16,
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    state.description,
                  ),
                ),
                Expanded(child: Image.network(state.largeIconUri.toString())),
                Text(
                  state.temperature.toText(state.temperatureUnit),
                  style: textTheme.displayMedium,
                ),
                gap16,
                Row(
                  children: [
                    const Text('Humidity:'),
                    gap16,
                    Text('${state.humidityPercent.round()}%'),
                  ],
                ),
                gap4,
                Row(
                  children: [
                    const Text('Pressure:'),
                    gap16,
                    Text('${state.pressureHPa.round()} hPa'),
                  ],
                ),
                gap4,
                Row(
                  children: [
                    const Text('Wind:'),
                    gap16,
                    Text('${state.windSpeedKmH.round()} km/h'),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 160, child: _buildList(context, state)),
      ],
    );
  }

  ListView _buildList(BuildContext context, LoadedState state) =>
      ListView.builder(
        padding: containerInsets,
        scrollDirection: Axis.horizontal,
        itemCount: state.days.length,
        itemBuilder: (context, index) {
          var item = state.days[index];
          var minText = item.minTemperature.toText(state.temperatureUnit);
          var text = item.maxTemperature.toText(state.temperatureUnit);
          return SizedBox(
            width: 88,
            child: InkResponse(
              onTap: () => context.read<WeatherCubit>().onDaySelected(index),
              child: GridTile(
                header: Text(
                  item.weekDay.shortText(),
                  textAlign: TextAlign.center,
                ),
                footer: Text('$minText/$text', textAlign: TextAlign.center),
                child: Image.network(item.smallIconUri.toString()),
              ),
            ),
          );
        },
      );
}

extension on WeekDay {
  String longText() => switch (this) {
        WeekDay.monday => 'Monday',
        WeekDay.tuesday => 'Tuesday',
        WeekDay.wednesday => 'Wednesday',
        WeekDay.thursday => 'Thursday',
        WeekDay.friday => 'Friday',
        WeekDay.saturday => 'Saturday',
        WeekDay.sunday => 'Sunday',
      };
  String shortText() => switch (this) {
        WeekDay.monday => 'Mon',
        WeekDay.tuesday => 'Tue',
        WeekDay.wednesday => 'Wed',
        WeekDay.thursday => 'Thu',
        WeekDay.friday => 'Fri',
        WeekDay.saturday => 'Sat',
        WeekDay.sunday => 'Sun',
      };
}

extension on Temperature {
  String toText(TemperatureUnit unit) => switch (unit) {
        TemperatureUnit.celsius => '${inCelsius.round()} °C',
        TemperatureUnit.fahrenheit => '${inFahrenheit.round()} °F',
      };
}
