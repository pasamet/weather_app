import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

const _jsonMimeType = 'application/json; charset=utf-8';
const _receiveJsonHeaders = {
  HttpHeaders.acceptHeader: _jsonMimeType,
};

typedef FromJsonObject<T> = T Function(Map<String, Object?> jsonObject);
typedef _FromJsonElement<T> = T Function(Object? jsonElement);

class JsonClient {
  final Client _client;

  JsonClient(Client client) : _client = client;

  Future<List<T>> getJsonObjectList<T>(Uri url, FromJsonObject<T> fromJson) =>
      _getJsonElement(url, (jsonElement) {
        if (jsonElement is List<Object?>) {
          return jsonElement
              .whereType<Map<String, Object?>>()
              .map(fromJson)
              .toList(growable: false);
        }
        throw Exception('Unexpected JSON element: $jsonElement');
      });

  Future<T> getJsonObject<T>(Uri url, FromJsonObject<T> fromJson) =>
      _getJsonElement(url, (jsonElement) {
        if (jsonElement is Map<String, Object?>) {
          return fromJson(jsonElement);
        }
        throw Exception('Unexpected JSON element: $jsonElement');
      });

  Future<T> _getJsonElement<T>(Uri url, _FromJsonElement<T> fromJson) async {
    var response = await _client.get(url, headers: _receiveJsonHeaders);
    if (response.statusCode == 200 && _isContentTypeJson(response)) {
      var jsonObject = _toJsonObject(response);
      return fromJson(jsonObject);
    }
    _fail(response);
  }

  Object? _toJsonObject(Response response) {
    var jsonString = utf8.decode(response.bodyBytes);
    var jsonObject = json.decode(jsonString);
    return jsonObject;
  }

  bool _isContentTypeJson(Response response) {
    var values = response.headersSplitValues[HttpHeaders.contentTypeHeader];
    return values?.length == 1 &&
        values!.first.toLowerCase().startsWith('application/json');
  }

  Never _fail(Response response) => throw HttpException(
        'Unexpected response: ${response.statusCode} ${response.reasonPhrase}',
        uri: response.request?.url,
      );
}
