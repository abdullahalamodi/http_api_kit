import 'package:flutter/services.dart';
import 'package:http/http.dart';

import '../http_api.dart';

abstract interface class HttpApiInterface {
  const HttpApiInterface();

  Client get httpClient;
  HttpApiConfig get config;
  Map<String, String>? get headers;
  MessagesInterface get messages;

  Future<T> post<T>({
    required String endPoint,
    Map<String, dynamic>? parameters,
    required Map<String, dynamic> body,
    required T Function(ResponseModelInterface responseModel) dataMapper,
  });

  Future<T> put<T>({
    required String endPoint,
    Map<String, dynamic>? parameters,
    required Map<String, dynamic> body,
    required T Function(ResponseModelInterface responseModel) dataMapper,
  });

  Future<T> delete<T>({
    required String endPoint,
    Map<String, dynamic>? parameters,
    required Map<String, dynamic> body,
    required T Function(ResponseModelInterface responseModel) dataMapper,
  });

  Future<T> multipart<T>({
    required String endPoint,
    String method,
    Map<String, dynamic>? parameters,
    required Map<String, String> fields,
    required List<MultipartFile> files,
    required T Function(ResponseModelInterface responseModel) dataMapper,
  });

  Future<T> getItem<T>({
    required String endPoint,
    Map<String, dynamic>? parameters,
    required T Function(ResponseModelInterface responseModel) dataMapper,
  });

  Future<T> getFile<T>({
    required String endPoint,
    Map<String, dynamic>? parameters,
    required T Function(Uint8List responseModel) dataMapper,
  });

  Future<T> getList<T>({
    required String endPoint,
    Map<String, dynamic>? parameters,
    required final T Function(
      ResponseModelInterface responseModel,
    ) dataMapper,
  });
}
