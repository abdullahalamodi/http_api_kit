// ignore_for_file: public_member_api_docs, sort_constructors_first
class HttpApiConfig {
  final String baseUrl;
  final String? apiAccessKey;
  final String? token;
  final String locale;

  HttpApiConfig({
    required this.baseUrl,
    required this.apiAccessKey,
    required this.token,
    required this.locale,
  });
}
