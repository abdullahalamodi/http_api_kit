import 'package:flutter/material.dart';

import 'response_model_interface.dart';

class ResponseModel implements ResponseModelInterface {
  @override
  final int statusCode;
  @override
  final bool success;
  @override
  final String? message;
  @override
  final dynamic data;

  ResponseModel({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  ResponseModel withSuccess(
    dynamic data, {
    int? statusCode,
    String? message,
  }) {
    return copyWith(
      statusCode: statusCode ?? 200,
      success: true,
      data: data,
      message: message != null ? () => message : null,
    );
  }

  ResponseModel withError({
    int? statusCode,
    String? message,
    dynamic data,
  }) {
    return copyWith(
      statusCode: statusCode,
      success: false,
      data: data,
      message: message != null ? () => message : null,
    );
  }

  ResponseModel copyWith({
    int? statusCode,
    bool? success,
    ValueGetter<String?>? message,
    dynamic data,
  }) {
    return ResponseModel(
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

  factory ResponseModel.fromMap(Map<String, dynamic> map) {
    return ResponseModel(
      statusCode: map['status_code']?.toInt() ?? 0,
      success: map['success'] ?? false,
      message: map['message'],
      data: map['data'],
    );
  }

  @override
  String toString() {
    return 'ResponseModel(statusCode: $statusCode, success: $success, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ResponseModel &&
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

@Deprecated('Use ResponseModel instead.')
class ResponseModelImp extends ResponseModel {
  ResponseModelImp({
    required super.statusCode,
    required super.success,
    required super.message,
    required super.data,
  });

  factory ResponseModelImp.fromMap(Map<String, dynamic> map) {
    return ResponseModelImp(
      statusCode: map['status_code']?.toInt() ?? 0,
      success: map['success'] ?? false,
      message: map['message'],
      data: map['data'],
    );
  }
}
