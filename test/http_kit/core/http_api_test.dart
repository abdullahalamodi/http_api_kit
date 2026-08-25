import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:http_api_kit/http_api_kit.dart';

void main() {
  test('maps an otherwise unknown exception with exceptionMapper', () async {
    final api = _createApi(
      exceptionMapper: (exception) {
        if (exception case _MapperFailure(:final message)) {
          return DataFormatException(message);
        }
        return null;
      },
    );

    await expectLater(
      api.getItem<void>(
        endPoint: '/items/1',
        dataMapper: (_) => throw _MapperFailure('missing full_name'),
      ),
      throwsA(
        isA<DataFormatException>().having(
          (exception) => exception.message,
          'message',
          contains('full_name'),
        ),
      ),
    );
  });

  test('falls back to UnknownException when the mapper returns null', () async {
    var mapperCalled = false;
    final api = _createApi(
      exceptionMapper: (_) {
        mapperCalled = true;
        return null;
      },
    );

    await expectLater(
      api.getItem<void>(
        endPoint: '/items/1',
        dataMapper: (_) => throw _MapperFailure('unexpected failure'),
      ),
      throwsA(
        isA<UnknownException>().having(
          (exception) => exception.message,
          'message',
          'UnKnown Error!',
        ),
      ),
    );
    expect(mapperCalled, isTrue);
  });

  test('does not invoke exceptionMapper for an existing HttpApiException',
      () async {
    var mapperCalled = false;
    final typedException = ServerException('server failure');
    final api = _createApi(
      exceptionMapper: (_) {
        mapperCalled = true;
        return DataFormatException('should not be used');
      },
    );

    await expectLater(
      api.getItem<void>(
        endPoint: '/items/1',
        dataMapper: (_) => throw typedException,
      ),
      throwsA(same(typedException)),
    );
    expect(mapperCalled, isFalse);
  });

  test('does not invoke exceptionMapper for FormatException', () async {
    var mapperCalled = false;
    final api = _createApi(
      exceptionMapper: (_) {
        mapperCalled = true;
        return DataFormatException('should not be used');
      },
    );

    await expectLater(
      api.getItem<void>(
        endPoint: '/items/1',
        dataMapper: (_) => throw const FormatException('invalid payload'),
      ),
      throwsA(
        isA<DataFormatException>().having(
          (exception) => exception.message,
          'message',
          'Data Formate Error',
        ),
      ),
    );
    expect(mapperCalled, isFalse);
  });

  test('does not invoke exceptionMapper for SocketException', () async {
    var mapperCalled = false;
    final api = _createApi(
      exceptionMapper: (_) {
        mapperCalled = true;
        return DataFormatException('should not be used');
      },
    );

    await expectLater(
      api.getItem<void>(
        endPoint: '/items/1',
        dataMapper: (_) => throw const SocketException('offline'),
      ),
      throwsA(
        isA<InternetException>().having(
          (exception) => exception.message,
          'message',
          'not internet connection',
        ),
      ),
    );
    expect(mapperCalled, isFalse);
  });
}

HttpApi<StandardResponseModel> _createApi({
  ExceptionMapper? exceptionMapper,
}) {
  return HttpApi<StandardResponseModel>(
    httpClient: MockClient(
      (_) async => Response(
        '{"status_code":200,"success":true,"data":{}}',
        200,
      ),
    ),
    config: HttpApiConfig(
      baseUrl: 'https://example.com',
      apiAccessKey: null,
      token: null,
      locale: 'en',
    ),
    exceptionMapper: exceptionMapper,
  );
}

final class _MapperFailure implements Exception {
  const _MapperFailure(this.message);

  final String message;
}
