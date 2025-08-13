import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_api_kit/http_api/http_api.dart';

final httpApiProvider = Provider.autoDispose<HttpApiInterface>((ref) {
  throw UnimplementedError();
});
