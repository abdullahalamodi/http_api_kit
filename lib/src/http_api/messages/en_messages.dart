// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../http_api.dart';

class EnMessages implements MessagesInterface {
  @override
  String get internetMessage => 'not internet connection';

  @override
  String get dataFormatMessage => 'Data Formate Error';

  @override
  String get unKnownMessage => 'UnKnown Error!';

  @override
  String get unKnownServerMessage => 'Uknown Server Error!';

  @override
  String get unauthorizedMessage => 'Unauthorized Please log in again';
}
