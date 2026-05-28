import 'response_model_interface.dart';

class DirectResponseModel implements ResponseModelInterface {
  @override
  int get statusCode => 200;
  @override
  bool get success => true;
  @override
  String? get message => null;
  @override
  final dynamic data;

  DirectResponseModel(this.data);

  factory DirectResponseModel.fromMap(Map<String, dynamic> map) {
    return DirectResponseModel(map);
  }

  @override
  String toString() {
    return 'DirectResponseModel(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DirectResponseModel && other.data == data;
  }

  @override
  int get hashCode {
    return data.hashCode;
  }
}

@Deprecated('Use DirectResponseModel instead.')
class DirectResponseModelImp extends DirectResponseModel {
  DirectResponseModelImp(super.data);

  factory DirectResponseModelImp.fromMap(Map<String, dynamic> map) {
    return DirectResponseModelImp(map);
  }
}
