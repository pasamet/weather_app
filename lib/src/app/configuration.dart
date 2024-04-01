final defaultConfiguration = Configuration(
  openWeatherApiHost: Uri.http('api.openweathermap.org'),
  openWeatherApiKey: '<ADD YOUR API KEY>',
);

class Configuration {
  final Uri openWeatherApiHost; // = ;
  final String openWeatherApiKey;

  Configuration({
    required this.openWeatherApiHost,
    required this.openWeatherApiKey,
  }); // = ;
}
