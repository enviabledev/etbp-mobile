class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => message;

  factory ApiException.fromDioError(dynamic error) {
    if (error.response != null) {
      final data = error.response?.data;
      String message = 'Something went wrong';
      if (data is Map) {
        message = data['detail'] ?? data['message'] ?? message;
      }
      return ApiException(
        message: message,
        statusCode: error.response?.statusCode,
        data: data,
      );
    }
    if (error.type.toString().contains('timeout')) {
      return ApiException(message: 'Connection timed out. Please try again.');
    }
    if (error.type.toString().contains('cancel')) {
      return ApiException(message: 'Request cancelled');
    }
    return ApiException(message: 'No internet connection. Please check your network.');
  }
}
