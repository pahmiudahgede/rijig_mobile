class ResponseModel {
  final int status;
  final String message;
  final Map<String, dynamic>? data;

  ResponseModel({required this.status, required this.message, this.data});

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      status: json['meta']?['status'] ?? 0,
      message: json['meta']?['message'] ?? '',
      data: json['data'],
    );
  }
}
