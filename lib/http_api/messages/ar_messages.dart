// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../http_api.dart';

class ArMessages implements MessagesInterface {
  @override
  String get internetMessage => 'لا يوجد اتصال بالانترنت';

  @override
  String get dataFormatMessage => 'خطاء في معالجة البيانات';

  @override
  String get unKnownMessage => 'خطاء غير معروف!';

  @override
  String get unKnownServerMessage => 'خطاء في السيرفر!';

  @override
  String get unauthorizedMessage => 'يرجى تسجيل الدخول';
}
