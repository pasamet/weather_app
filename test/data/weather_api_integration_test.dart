import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:weather_app/src/data/json_client.dart';
import 'package:weather_app/src/data/weather_api.dart';

void main() {
  late WeatherApi sut;
  Response? response;
  Request? request;

  setUp(() {
    request = null;
    var httpClient = MockClient((req) async {
      request = req;
      return response!;
    });
    var jsonClient = JsonClient(httpClient);
    sut = WeatherApi(
      client: jsonClient,
      baseUri: Uri.https('example.com'),
      apiKey: 'api_key',
    );
  });

  test('When location is searched Then returns results', () async {
    response = Response(
      '['
      '{"name":"Berlin",'
      '"local_names":{"de":"Berlin"},'
      '"lat":52.5170365,"lon":13.3888599,'
      '"country":"DE"},'
      '{"name":"Berlin",'
      '"lat":44.4688795,"lon":-71.1836547,'
      '"country":"US","state":"New Hampshire"}'
      ']',
      200,
      headers: {
        'content-type': 'application/json; charset=utf-8',
      },
    );

    var actual = await sut.directGeocoding('berlin');

    expect(
      request?.url.toString(),
      'https://example.com/geo/1.0/direct?q=berlin&limit=20&appid=api_key',
    );
    expect(actual, isNotEmpty);
  });
}
