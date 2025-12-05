import 'response_model_interface.dart';

class DirectResponseModelImp implements ResponseModelInterface {
  @override
  int get statusCode => 200;
  @override
  bool get success => true;
  @override
  String? get message => null;
  @override
  final dynamic data;

  DirectResponseModelImp(this.data);

  factory DirectResponseModelImp.fromMap(Map<String, dynamic> map) {
    return DirectResponseModelImp(map);
  }

  @override
  String toString() {
    return 'DirectResponseModelImp( data: $data)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DirectResponseModelImp && other.data == data;
  }

  @override
  int get hashCode {
    return data.hashCode;
  }
}
