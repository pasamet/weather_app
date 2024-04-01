import 'package:flutter/material.dart';

import '../../data/geocoding_repository.dart';

class WeatherScreen extends StatelessWidget {
  final NamedLocation location;

  const WeatherScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(location.name),
        ),
      );
}
