import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../helpers/dio_exceptions.dart';

String baseUrl = 'https://nominatim.openstreetmap.org/search';
String responseFormat = 'json';
String bounded = '1';
String searchResultsLimit = '5';
String viewbox = '122.86794,10.36986,122.87134,10.36829';

Dio _dio = Dio();

Future getSearchResultsFromQueryUsingMapbox(String query) async {
  String url =
      '$baseUrl?format=$responseFormat&bounded=$bounded&limit=$searchResultsLimit&viewbox=$viewbox&q=$query';
  url = Uri.parse(url).toString();
  debugPrint(url);
  try {
    _dio.options.contentType = Headers.jsonContentType;
    final responseData = await _dio.get(url);
    return responseData.data;
  } catch (e) {
    final errorMessage = DioExceptions.fromDioError(e as DioException).toString();
    debugPrint(errorMessage);
  }
}
