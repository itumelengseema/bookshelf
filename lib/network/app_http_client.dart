import 'dart:convert';

import 'package:bookshelf/network/api_result.dart';
import 'package:http/http.dart' as http;

class AppHttpClient {
  final http.Client client;

  AppHttpClient({http.Client? client}) : client = client ?? http.Client();

  Future<ApiResult<dynamic>> get(String url) async {
    try {
      final response = await client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decodedBody = jsonDecode(response.body);
        return ApiSuccess(decodedBody);
      }

      return ApiFailure('Request failed with status: ${response.statusCode}');
    } catch (error) {
      return ApiFailure('Something went wrong: $error');
    }
  }
}
