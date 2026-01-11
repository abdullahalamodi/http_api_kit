import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http_interceptor/http_interceptor.dart';

import '../http_api.dart';

class HttpApi implements HttpApiInterface {
  HttpApi({
    required this.httpClient,
    required this.config,
    Map<String, dynamic>? customParameters,
    Map<String, String>? customHeaders,
    this.responseParser,
  })  : messages = MessagesFactory(config.locale).messages,
        headers = customHeaders ?? _buildHeaders(config),
        globalParameters = customParameters ?? _buildGloableParamiters(config);

  @override
  final Client httpClient;

  @override
  final HttpApiConfig config;

  @override
  final Map<String, String>? headers;

  final Map<String, dynamic>? globalParameters;

  @override
  final MessagesInterface messages;

  @override
  final ResponseParser? responseParser;

  Uri _getUri(
    String endPoint, {
    Map<String, dynamic>? parameters,
  }) {
    final uri = Uri.parse('${config.baseUrl}$endPoint');
    return uri.addParameters(globalParameters).addParameters(parameters);
  }

  static Map<String, dynamic> _buildGloableParamiters(HttpApiConfig config) {
    return {
      'locale': config.locale,
    };
  }

  static Map<String, String> _buildHeaders(HttpApiConfig config) {
    return {
      'Accept': '*/*',
      'Content-Type': 'application/json',
      if (config.apiAccessKey != null) 'API-ACCESS-KEY': config.apiAccessKey!,
      if (config.token != null) 'ACCESS-TOKEN': config.token!,
    };
  }

  Future<T> _handleResponse<T>({
    required Response response,
    required T Function(ResponseModelInterface responseModel) dataMapper,
    ResponseParser? customResponseParser,
  }) async {
    final data = json.decode(response.body);
    ResponseModelInterface responseModel;
    if (customResponseParser != null) {
      responseModel = customResponseParser(data);
    } else {
      responseModel = ResponseModelImp.fromMap(data); // Default
    }

    if (responseModel.success) {
      return dataMapper.call(responseModel);
    } else {
      throw ServerException(
        responseModel.message ?? messages.unKnownServerMessage,
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<T> getItem<T>({
    required String endPoint,
    Map<String, dynamic>? parameters,
    required final T Function(ResponseModelInterface responseModel) dataMapper,
    ResponseParser? customResponseParser,
  }) async {
    try {
      final uri = _getUri(endPoint, parameters: parameters);

      /// log request
      CustomLogger.requestLogger(uri: uri, method: 'GET', headers: headers);

      ///
      final response = await httpClient.get(uri, headers: headers);

      /// log response
      CustomLogger.responseLogger(response);

      final data = await _handleResponse(
        response: response,
        dataMapper: dataMapper,
        customResponseParser: responseParser ?? customResponseParser,
      );
      return data;
    } catch (e, s) {
      _logError(e, s);
      throw _switchError(e);
    }
  }

  @override
  Future<T> getList<T>({
    required String endPoint,
    String? method,
    Map<String, dynamic>? parameters,
    required T Function(ResponseModelInterface responseModel) dataMapper,
    ResponseParser? customResponseParser,
  }) async {
    try {
      final uri = _getUri(endPoint, parameters: parameters);

      /// log request
      CustomLogger.requestLogger(uri: uri, method: 'GET', headers: headers);

      ///
      final response = await httpClient.get(uri, headers: headers);

      /// log response
      CustomLogger.responseLogger(response);

      final data = await _handleResponse(
        response: response,
        dataMapper: dataMapper,
        customResponseParser: responseParser ?? customResponseParser,
      );
      return data;
    } catch (e, s) {
      _logError(e, s);
      throw _switchError(e);
    }
  }

  @override
  Future<T> post<T>({
    required String endPoint,
    Map<String, dynamic>? parameters,
    required Map<String, dynamic> body,
    required T Function(ResponseModelInterface responseModel) dataMapper,
    ResponseParser? customResponseParser,
  }) async {
    try {
      final uri = _getUri(endPoint, parameters: parameters);

      /// log request
      CustomLogger.requestLogger(uri: uri, method: 'POST', headers: headers);

      ///
      final response = await httpClient.post(
        uri,
        headers: headers,
        body: json.encode(body),
      );

      /// log response
      CustomLogger.responseLogger(response);

      final data = await _handleResponse(
        response: response,
        dataMapper: dataMapper,
        customResponseParser: responseParser ?? customResponseParser,
      );
      return data;
    } catch (e, s) {
      _logError(e, s);
      throw _switchError(e);
    }
  }

  @override
  Future<T> put<T>({
    required String endPoint,
    Map<String, dynamic>? parameters,
    required Map<String, dynamic> body,
    required T Function(ResponseModelInterface responseModel) dataMapper,
    ResponseParser? customResponseParser,
  }) async {
    try {
      final uri = _getUri(endPoint, parameters: parameters);

      /// log request
      CustomLogger.requestLogger(uri: uri, method: 'PUT', headers: headers);

      ///
      final response = await httpClient.put(
        uri,
        headers: headers,
        body: json.encode(body),
      );

      /// log response
      CustomLogger.responseLogger(response);

      final data = await _handleResponse(
        response: response,
        dataMapper: dataMapper,
        customResponseParser: responseParser ?? customResponseParser,
      );
      return data;
    } catch (e, s) {
      _logError(e, s);
      throw _switchError(e);
    }
  }

  @override
  Future<T> getFile<T>({
    required String endPoint,
    Map<String, dynamic>? parameters,
    required final T Function(Uint8List bodyBytes) dataMapper,
    ResponseParser? customResponseParser,
  }) async {
    try {
      final uri = _getUri(endPoint, parameters: parameters);

      /// log request
      CustomLogger.requestLogger(uri: uri, method: 'GET', headers: headers);

      ///
      final response = await httpClient.get(uri, headers: headers);

      /// log response
      CustomLogger.responseLogger(response);

      if (response.statusCode == 200) {
        final data = dataMapper.call(response.bodyBytes);
        return data;
      } else {
        throw ServerException(
          messages.unKnownServerMessage,
          statusCode: response.statusCode,
        );
      }
    } catch (e, s) {
      _logError(e, s);
      throw _switchError(e);
    }
  }

  @override
  Future<T> delete<T>({
    required String endPoint,
    Map<String, dynamic>? parameters,
    required Map<String, dynamic> body,
    required T Function(ResponseModelInterface responseModel) dataMapper,
    ResponseParser? customResponseParser,
  }) async {
    try {
      final uri = _getUri(endPoint, parameters: parameters);

      /// log request
      CustomLogger.requestLogger(uri: uri, method: 'DELETE', headers: headers);

      ///
      final response = await httpClient.delete(
        uri,
        headers: headers,
        body: json.encode(body),
      );

      /// log response
      CustomLogger.responseLogger(response);

      final data = await _handleResponse(
        response: response,
        dataMapper: dataMapper,
        customResponseParser: responseParser ?? customResponseParser,
      );
      return data;
    } catch (e, s) {
      _logError(e, s);
      throw _switchError(e);
    }
  }

  @override
  Future<T> multipart<T>({
    required String endPoint,
    String method = 'POST',
    Map<String, dynamic>? parameters,
    required List<MultipartFile> files,
    required Map<String, String> fields,
    required T Function(ResponseModelInterface responseModel) dataMapper,
    ResponseParser? customResponseParser,
  }) async {
    try {
      final uri = _getUri(endPoint);

      /// log request
      CustomLogger.requestLogger(
        uri: uri,
        method: method,
        headers: headers,
        body: fields,
        files: files,
      );

      final request = MultipartRequest(
        method,
        uri,
      );

      request.headers.addAll(headers!);
      if (fields.isNotEmpty) {
        request.fields.addAll(fields);
      }
      request.files.addAll(files);

      ///
      final streamResponse = await httpClient.send(request);
      final response = await Response.fromStream(streamResponse);

      /// log response
      CustomLogger.responseLogger(response);

      final data = await _handleResponse(
        response: response,
        dataMapper: dataMapper,
        customResponseParser: responseParser ?? customResponseParser,
      );
      return data;
    } catch (e, s) {
      _logError(e, s);
      throw _switchError(e);
    }
  }

  HttpApiException _switchError(Object e) {
    switch (e) {
      case ServerException():
        return ServerException(e.message);

      case SocketException():
        return InternetException(messages.internetMessage);

      case FormatException():
        return DataFormatException(messages.dataFormatMessage);

      default:
        return UnknownException(messages.unKnownMessage);
    }
  }

  void _logError(Object e, StackTrace s) {
    CustomLogger.exceptionLogger(
      msg: 'http api',
      error: e,
      stackTrace: s,
    );
  }
}
