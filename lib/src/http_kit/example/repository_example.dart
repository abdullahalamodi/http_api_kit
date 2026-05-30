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

// // With a custom response model type — no casting needed in dataMapper:
// //
// // class MyResponseModel implements ResponseModelInterface {
// //   final int statusCode;
// //   final bool success;
// //   final String? message;
// //   final dynamic data;
// //   final PaginationModel? pagination;
// //   // ...
// // }
// //
// // final _typedApiProvider = Provider.autoDispose<HttpApiInterface<MyResponseModel>>((ref) {
// //   return HttpApi<MyResponseModel>(
// //     httpClient: ...,
// //     config: ...,
// //     responseParser: (json) => MyResponseModel.fromMap(json),
// //   );
// // });

// class RepositotyExample {
//   final Ref ref;

//   RepositotyExample({required this.ref});

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
//           dataMapper: (response) {
//             return PaginatedDataModel(
//               data: response.data['data_response_key'] as List<String>,
//               pagination: PaginationModel.fromJson(
//                 Map<String, dynamic>.from(
//                   response.data['pagination_response_key'],
//                 ),
//               ),
//             );
//           },
//         );
//     return items;
//   }
// }
