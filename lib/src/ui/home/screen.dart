import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../data/geocoding_repository.dart';
import '../weather/screen.dart';
import 'content.dart';
import 'cubit.dart';

final _getIt = GetIt.instance;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements HomeActions {
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => HomeCubit(repository: _getIt(), actions: this),
        child: const HomeContent(),
      );

  @override
  void navigateToWeather(NamedLocation location) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WeatherScreen(
          location: location,
        ),
      ),
    );
  }
}
