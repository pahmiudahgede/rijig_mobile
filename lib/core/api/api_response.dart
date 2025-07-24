class ApiResponse<T> {
  final T? data;
  final String message;
  final int statusCode;
  final bool isSuccess;
  final String? error;

  ApiResponse._({
    this.data,
    required this.message,
    required this.statusCode,
    required this.isSuccess,
    this.error,
  });

  factory ApiResponse.success({
    required T data,
    required int statusCode,
    String message = 'Success',
  }) {
    return ApiResponse._(
      data: data,
      message: message,
      statusCode: statusCode,
      isSuccess: true,
    );
  }

  factory ApiResponse.error({
    required String message,
    required int statusCode,
    String? error,
  }) {
    return ApiResponse._(
      message: message,
      statusCode: statusCode,
      isSuccess: false,
      error: error,
    );
  }
}