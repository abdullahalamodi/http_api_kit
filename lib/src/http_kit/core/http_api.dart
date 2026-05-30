import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http_interceptor/http_interceptor.dart';

import '../http_kit.dart';

class HttpApi implements HttpApiInterface {
  HttpApi({
    required this.httpClient,
    required this.config,
    Map<String, dynamic>? customParameters,
    Map<String, String>? customHeaders,
    this.responseParser,
    HttpApiLogger? logger,
  })  : messages = MessagesFactory(config.locale).messages,
        headers = customHeaders ?? _buildHeaders(config),
        logger = logger ?? const NoopHttpApiLogger(),
        globalParameters = customParameters ?? _buildGlobalParameters(config);

  @override
  final Client httpClient;

  @override
  final HttpApiConfig config;

  @override
  final Map<String, String> headers;

  final Map<String, dynamic> globalParameters;

  @override
  final MessagesInterface messages;

  @override
  final ResponseParser? responseParser;

  @override
  final HttpApiLogger logger;

  Uri _getUri(
    String endPoint, {
    Map<String, dynamic>? parameters,
  }) {
    final uri = Uri.parse('${config.baseUrl}$endPoint');
    return uri.addParameters(globalParameters).addParameters(parameters);
  }

  static Map<String, dynamic> _buildGlobalParameters(HttpApiConfig config) {
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

  Map<String, String> _mergeHeaders(Map<String, String>? requestHeaders) {
    return {
      ...headers,
      if (requestHeaders != null) ...requestHeaders,
    };
  }

  Future<T> _sendJsonRequest<T>({
    required String endPoint,
    required String method,
    Map<String, dynamic>? parameters,
    Map<String, String>? requestHeaders,
    Map<String, dynamic>? body,
    required T Function(ResponseModelInterface responseModel) dataMapper,
    ResponseParser? customResponseParser,
  }) async {
    try {
      final uri = _getUri(endPoint, parameters: parameters);
      final mergedHeaders = _mergeHeaders(requestHeaders);

      logger.logRequest(HttpApiRequestLog(
        uri: uri,
        method: method,
        headers: mergedHeaders,
        body: body ?? const {},
      ));

      final response = switch (method) {
        'GET' => await httpClient.get(uri, headers: mergedHeaders),
        'POST' => await httpClient.post(
            uri,
            headers: mergedHeaders,
            body: json.encode(body ?? const {}),
          ),
        'PUT' => await httpClient.put(
            uri,
            headers: mergedHeaders,
            body: json.encode(body ?? const {}),
          ),
        'DELETE' => await httpClient.delete(
            uri,
            headers: mergedHeaders,
            body: json.encode(body ?? const {}),
          ),
        _ => throw UnsupportedError('HTTP method $method is not supported.'),
      };

      // logger.logResponse(HttpApiResponseLog(response));

      return _handleResponse(
        response: response,
        dataMapper: dataMapper,
        customResponseParser: customResponseParser,
      );
    } catch (e, s) {
      _logError(e, s);
      throw _switchError(e);
    }
  }

  Future<T> _handleResponse<T>({
    required Response response,
    required T Function(ResponseModelInterface responseModel) dataMapper,
    ResponseParser? customResponseParser,
  }) async {
    if (!_isSuccessStatusCode(response.statusCode)) {
      throw ServerException(
        _errorMessageFromResponse(response, customResponseParser),
        statusCode: response.statusCode,
      );
    }
    logger.logResponse(HttpApiResponseLog(response));

    final data = json.decode(response.body);
    final responseModel = _parseResponseModel(data, customResponseParser);

    if (responseModel.success) {
      return dataMapper.call(responseModel);
    }

    throw ServerException(
      responseModel.message ?? messages.unKnownServerMessage,
      statusCode: response.statusCode,
    );
  }

  bool _isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  String _errorMessageFromResponse(
    Response response,
    ResponseParser? customResponseParser,
  ) {
    try {
      final data = json.decode(response.body);
      final responseModel = _parseResponseModel(data, customResponseParser);
      return responseModel.message ?? messages.unKnownServerMessage;
    } on FormatException {
      return messages.unKnownServerMessage;
    } catch (_) {
      return messages.unKnownServerMessage;
    }
  }

  ResponseModelInterface _parseResponseModel(
    dynamic data,
    ResponseParser? customResponseParser,
  ) {
    if (customResponseParser != null) {
      return customResponseParser.call(data);
    } else if (responseParser != null) {
      return responseParser!.call(data);
    } else {
      return StandardResponseModel.fromMap(data);
    }
  }

  @override
  Future<T> getItem<T>({
    required String endPoint,
    Map<String, dynamic>? parameters,
    Map<String, String>? requestHeaders,
    required T Function(ResponseModelInterface responseModel) dataMapper,
    ResponseParser? customResponseParser,
  }) {
    return _sendJsonRequest(
      endPoint: endPoint,
      method: 'GET',
      parameters: parameters,
      requestHeaders: requestHeaders,
      dataMapper: dataMapper,
      customResponseParser: customResponseParser,
    );
  }

  @override
  Future<T> getList<T>({
    required String endPoint,
    String? method,
    Map<String, dynamic>? parameters,
    Map<String, String>? requestHeaders,
    required T Function(ResponseModelInterface responseModel) dataMapper,
    ResponseParser? customResponseParser,
  }) {
    return _sendJsonRequest(
      endPoint: endPoint,
      method: method ?? 'GET',
      parameters: parameters,
      requestHeaders: requestHeaders,
      dataMapper: dataMapper,
      customResponseParser: customResponseParser,
    );
  }

  @override
  Future<T> post<T>({
    required String endPoint,
    Map<String, dynamic>? parameters,
    Map<String, String>? requestHeaders,
    required Map<String, dynamic> body,
    required T Function(ResponseModelInterface responseModel) dataMapper,
    ResponseParser? customResponseParser,
  }) {
    return _sendJsonRequest(
      endPoint: endPoint,
      method: 'POST',
      parameters: parameters,
      requestHeaders: requestHeaders,
      body: body,
      dataMapper: dataMapper,
      customResponseParser: customResponseParser,
    );
  }

  @override
  Future<T> put<T>({
    required String endPoint,
    Map<String, dynamic>? parameters,
    Map<String, String>? requestHeaders,
    required Map<String, dynamic> body,
    required T Function(ResponseModelInterface responseModel) dataMapper,
    ResponseParser? customResponseParser,
  }) {
    return _sendJsonRequest(
      endPoint: endPoint,
      method: 'PUT',
      parameters: parameters,
      requestHeaders: requestHeaders,
      body: body,
      dataMapper: dataMapper,
      customResponseParser: customResponseParser,
    );
  }

  @override
  Future<T> getFile<T>({
    required String endPoint,
    Map<String, dynamic>? parameters,
    Map<String, String>? requestHeaders,
    required T Function(Uint8List bodyBytes) dataMapper,
    ResponseParser? customResponseParser,
  }) async {
    try {
      final uri = _getUri(endPoint, parameters: parameters);
      final mergedHeaders = _mergeHeaders(requestHeaders);

      logger.logRequest(HttpApiRequestLog(
        uri: uri,
        method: 'GET',
        headers: mergedHeaders,
      ));

      final response = await httpClient.get(uri, headers: mergedHeaders);

      logger.logResponse(HttpApiResponseLog(response));

      if (_isSuccessStatusCode(response.statusCode)) {
        return dataMapper.call(response.bodyBytes);
      }

      throw ServerException(
        _errorMessageFromResponse(response, customResponseParser),
        statusCode: response.statusCode,
      );
    } catch (e, s) {
      _logError(e, s);
      throw _switchError(e);
    }
  }

  @override
  Future<T> delete<T>({
    required String endPoint,
    Map<String, dynamic>? parameters,
    Map<String, String>? requestHeaders,
    required Map<String, dynamic> body,
    required T Function(ResponseModelInterface responseModel) dataMapper,
    ResponseParser? customResponseParser,
  }) {
    return _sendJsonRequest(
      endPoint: endPoint,
      method: 'DELETE',
      parameters: parameters,
      requestHeaders: requestHeaders,
      body: body,
      dataMapper: dataMapper,
      customResponseParser: customResponseParser,
    );
  }

  @override
  Future<T> multipart<T>({
    required String endPoint,
    String method = 'POST',
    Map<String, dynamic>? parameters,
    Map<String, String>? requestHeaders,
    required List<MultipartFile> files,
    required Map<String, String> fields,
    required T Function(ResponseModelInterface responseModel) dataMapper,
    ResponseParser? customResponseParser,
  }) async {
    try {
      final uri = _getUri(endPoint, parameters: parameters);
      final mergedHeaders = _mergeHeaders(requestHeaders);

      logger.logRequest(HttpApiRequestLog(
        uri: uri,
        method: method,
        headers: mergedHeaders,
        body: fields,
        files: files,
      ));

      final request = MultipartRequest(method, uri);

      request.headers.addAll(mergedHeaders);
      if (fields.isNotEmpty) {
        request.fields.addAll(fields);
      }
      request.files.addAll(files);

      final streamResponse = await httpClient.send(request);
      final response = await Response.fromStream(streamResponse);

      logger.logResponse(HttpApiResponseLog(response));

      return _handleResponse(
        response: response,
        dataMapper: dataMapper,
        customResponseParser: customResponseParser,
      );
    } catch (e, s) {
      _logError(e, s);
      throw _switchError(e);
    }
  }

  HttpApiException _switchError(Object e) {
    switch (e) {
      case HttpApiException():
        return e;

      case SocketException():
        return InternetException(messages.internetMessage);

      case FormatException():
        return DataFormatException(messages.dataFormatMessage);

      default:
        return UnknownException(messages.unKnownMessage);
    }
  }

  void _logError(Object e, StackTrace s) {
    logger.logException(e, s);
  }
}
