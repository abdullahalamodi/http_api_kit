import 'package:flutter/material.dart';

import 'response_model_interface.dart';

class ResponseModelImp implements ResponseModelInterface {
  @override
  final int statusCode;
  @override
  final bool success;
  @override
  final String? message;
  @override
  final dynamic data;

  ResponseModelImp({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  ResponseModelImp copyWith({
    int? statusCode,
    bool? success,
    ValueGetter<String?>? message,
    dynamic data,
  }) {
    return ResponseModelImp(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      message: message != null ? message() : this.message,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status_code': statusCode,
      'success': success,
      'message': message,
      'data': data,
    };
  }

  factory ResponseModelImp.fromMap(Map<String, dynamic> map) {
    return ResponseModelImp(
      statusCode: map['status_code']?.toInt() ?? 0,
      success: map['success'] ?? false,
      message: map['message'],
      data: map['data'],
    );
  }

  @override
  String toString() {
    return 'ResponseModelImp(statusCode: $statusCode, success: $success, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ResponseModelImp &&
        other.statusCode == statusCode &&
        other.success == success &&
        other.message == message &&
        other.data == data;
  }

  @override
  int get hashCode {
    return statusCode.hashCode ^
        success.hashCode ^
        message.hashCode ^
        data.hashCode;
  }
}
