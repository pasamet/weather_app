import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../data/geocoding_repository.dart';
import 'content.dart';
import 'cubit.dart';

final _getIt = GetIt.instance;

class WeatherScreen extends StatefulWidget {
  final NamedLocation location;

  const WeatherScreen({super.key, required this.location});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => WeatherCubit(_getIt(), widget.location),
        child: const WeatherContent(),
      );
}
