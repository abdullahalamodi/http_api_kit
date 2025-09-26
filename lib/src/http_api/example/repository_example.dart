// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http_api_kit/async_widgets_kit/async_widgets_kit.dart';
// import 'package:http_api_kit/http_api/http_api.dart';
// import 'package:http_interceptor/http_interceptor.dart';

// final repoExampleProvider = Provider<RepositotyExample>((ref) {
//   return RepositotyExample(ref: ref);
// });

// final _httpApiProvider = Provider.autoDispose<HttpApiInterface>((ref) {
//   final httpCLient = InterceptedClient.build(interceptors: []);
//   final httpApiConfig = HttpApiConfig(
//     baseUrl: 'YOUR_BASE_URL',
//     locale: 'en',
//     apiAccessKey: 'YOUR_API_ACCESS_KEY',
//     token: 'YOUR_TOKEN',
//   );
//   return HttpApi(
//     httpClient: httpCLient,
//     config: httpApiConfig,
//   );
// });

// class RepositotyExample {
//   final Ref ref;

//   RepositotyExample({required this.ref});

//   Future<ResponseModelInterface> postItem() async {
//     final response =
//         await ref.read(_httpApiProvider).post<ResponseModelInterface>(
//               endPoint: 'YOUR_END_POINT',
//               body: {'name': 'item1'},
//               dataMapper: (data) => data,
//             );
//     return response;
//   }

//   Future<String> getItem() async {
//     final item = await ref.read(_httpApiProvider).getItem<String>(
//           endPoint: 'YOUR_END_POINT',
//           dataMapper: (data) => data.data as String,
//         );
//     return item;
//   }

//   Future<PaginatedDataModel<String>> getList() async {
//     final items = await ref.read(_httpApiProvider).getList(
//           endPoint: 'YOUR_END_POINT',
//           // you can here extaract data.responskey [cities, users, ...etc]
//           // and paginaton key
//           dataMapper: (response) {
//             return PaginatedDataModel(
//               data: response.data['data_response_key'] as List<String>,
//               pagination: response.data['pagination_response_key'],
//             );
//           },
//         );
//     return items;
//   }
// }
