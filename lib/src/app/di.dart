// ignore_for_file: directives_ordering

import 'package:get_it/get_it.dart';
import 'package:http/http.dart';

import '../data/geocoding_repository.dart';
import '../data/json_client.dart';
import '../data/weather_api.dart';
import '../data/weather_repository.dart';
import 'configuration.dart';

Future<void> setupDependencies(Configuration configuration) async {
  var getIt = GetIt.instance;
  await getIt.reset();
  getIt
    ..registerSingleton(configuration)
    ..registerLazySingleton(Client.new, dispose: (instance) => instance.close())
    ..registerLazySingleton(() => JsonClient(getIt()))
    ..registerLazySingleton(
      () {
        var configuration = getIt<Configuration>();
        return WeatherApi(
          client: getIt(),
          apiKey: configuration.openWeatherApiKey,
          baseUri: configuration.openWeatherApiHost,
        );
      },
    )
    ..registerLazySingleton(
      () => GeocodingRepository(api: getIt()),
    )
    ..registerLazySingleton(
      () => WeatherRepository(api: getIt()),
    );
  await getIt.allReady();
}
