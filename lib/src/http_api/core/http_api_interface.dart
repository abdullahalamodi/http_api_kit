import 'package:flutter/services.dart';
import 'package:http/http.dart';

import '../http_api.dart';

typedef ResponseParser = ResponseModelInterface Function(dynamic json);

abstract interface class HttpApiInterface {
  const HttpApiInterface();

  Client get httpClient;
  HttpApiConfig get config;
  Map<String, String> get headers;
  MessagesInterface get messages;
  ResponseParser? get responseParser;
  HttpApiLogger get logger;

  Future<T> post<T>({
    required String endPoint,
    Map<String, dynamic>? parameters,
    Map<String, String>? requestHeaders,
    required Map<String, dynamic> body,
    required T Function(ResponseModelInterface responseModel) dataMapper,
    ResponseParser? customResponseParser,
  });

  Future<T> put<T>({
    required String endPoint,
    Map<String, dynamic>? parameters,
    Map<String, String>? requestHeaders,
    required Map<String, dynamic> body,
    required T Function(ResponseModelInterface responseModel) dataMapper,
    ResponseParser? customResponseParser,
  });

  Future<T> delete<T>({
    required String endPoint,
    Map<String, dynamic>? parameters,
    Map<String, String>? requestHeaders,
    required Map<String, dynamic> body,
    required T Function(ResponseModelInterface responseModel) dataMapper,
    ResponseParser? customResponseParser,
  });

  Future<T> multipart<T>({
    required String endPoint,
    String method,
    Map<String, dynamic>? parameters,
    Map<String, String>? requestHeaders,
    required Map<String, String> fields,
    required List<MultipartFile> files,
    required T Function(ResponseModelInterface responseModel) dataMapper,
    ResponseParser? customResponseParser,
  });

  Future<T> getItem<T>({
    required String endPoint,
    Map<String, dynamic>? parameters,
    Map<String, String>? requestHeaders,
    required T Function(ResponseModelInterface responseModel) dataMapper,
    ResponseParser? customResponseParser,
  });

  Future<T> getFile<T>({
    required String endPoint,
    Map<String, dynamic>? parameters,
    Map<String, String>? requestHeaders,
    required T Function(Uint8List responseModel) dataMapper,
    ResponseParser? customResponseParser,
  });

  Future<T> getList<T>({
    required String endPoint,
    String? method,
    Map<String, dynamic>? parameters,
    Map<String, String>? requestHeaders,
    required final T Function(ResponseModelInterface responseModel) dataMapper,
    ResponseParser? customResponseParser,
  });
}
