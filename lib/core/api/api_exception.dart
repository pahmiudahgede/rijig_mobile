enum NetworkErrorType {
  noConnection,
  connectionFailed,
  timeout,
  poor,
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? details;

  ApiException(this.message, this.statusCode, [this.details]);

  @override
  String toString() {
    return 'ApiException: $message (Status Code: $statusCode)';
  }
}

class NetworkException implements Exception {
  final String message;
  final NetworkErrorType type;

  NetworkException(this.message, this.type);

  @override
  String toString() => 'NetworkException: $message';
}