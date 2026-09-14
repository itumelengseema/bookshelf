abstract interface class HttpClient {
  Future<HttpResponse> get(String url);
}

class HttpResponse {
  final int statusCode;
  final String body;

  HttpResponse({required this.statusCode, required this.body});
}
