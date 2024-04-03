import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/weather_repository.dart';
import '../common/dimensions.dart';
import 'cubit.dart';

class WeatherContent extends StatelessWidget {
  WeatherContent({super.key});
  final _refreshKey = GlobalKey<RefreshIndicatorState>(debugLabel: 'refresh');
  @override
  Widget build(BuildContext context) => BlocBuilder<WeatherCubit, WeatherState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text(state.title),
            actions: [
              if (!_isMobilePlatform(context))
                IconButton(
                  onPressed: () => _refreshKey.currentState?.show(),
                  icon: const Icon(Icons.refresh),
                ),
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

  Widget _buildLoaded(BuildContext context, LoadedState state) =>
      OrientationBuilder(
        builder: (context, orientation) => switch (orientation) {
          Orientation.portrait => Column(
              children: [
                Expanded(
                  child: _wrapInRefreshIndicator(
                    state,
                    _buildLoadedContent(context, state),
                  ),
                ),
                _buildList(context, state, Axis.horizontal),
              ],
            ),
          Orientation.landscape => Row(
              children: [
                Expanded(
                  child: _wrapInRefreshIndicator(
                    state,
                    _buildLoadedContent(context, state),
                  ),
                ),
                _buildList(context, state, Axis.vertical),
              ],
            ),
        },
      );

  Widget _wrapInRefreshIndicator(LoadedState state, Widget child) =>
      LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) =>
            RefreshIndicator(
          key: _refreshKey,
          onRefresh: () => context.read<WeatherCubit>().onRefresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: child,
              ),
            ),
          ),
        ),
      );

  Widget _buildLoadedContent(BuildContext context, LoadedState state) {
    var textTheme = Theme.of(context).textTheme;
    return Padding(
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
          Image.network(
            height: 200,
            width: 200,
            state.largeIconUri.toString(),
            fit: BoxFit.scaleDown,
          ),
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
    );
  }

  Widget _buildList(
    BuildContext context,
    LoadedState state,
    Axis scrollDirection,
  ) =>
      SizedBox(
        height: scrollDirection == Axis.horizontal ? 160 : null,
        width: scrollDirection == Axis.vertical ? 160 : null,
        child: ListView.builder(
          padding: containerInsets,
          scrollDirection: scrollDirection,
          itemCount: state.days.length,
          itemBuilder: (context, index) => _buildItem(context, state, index),
        ),
      );

  Material _buildItem(BuildContext context, LoadedState state, int index) {
    var item = state.days[index];
    var minText = item.minTemperature.toText(state.temperatureUnit);
    var text = item.maxTemperature.toText(state.temperatureUnit);
    var colorsScheme = Theme.of(context).colorScheme;
    var selected = index == state.selectedDayIndex;
    var textStyle = TextStyle(color: selected ? colorsScheme.primary : null);
    return Material(
      borderRadius: BorderRadius.circular(8),
      color: selected ? colorsScheme.primaryContainer : null,
      child: SizedBox(
        width: 120,
        height: 120,
        child: InkResponse(
          onTap: () => context.read<WeatherCubit>().onDaySelected(index),
          child: GridTile(
            header: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                item.weekDay.shortText(),
                textAlign: TextAlign.center,
                style: textStyle,
              ),
            ),
            footer: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '$minText/$text',
                textAlign: TextAlign.center,
                style: textStyle,
              ),
            ),
            child: Image.network(item.smallIconUri.toString()),
          ),
        ),
      ),
    );
  }
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

bool _isMobilePlatform(BuildContext context) => {
      TargetPlatform.iOS,
      TargetPlatform.android,
    }.contains(Theme.of(context).platform);
