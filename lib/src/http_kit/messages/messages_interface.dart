abstract interface class MessagesInterface {
  const MessagesInterface();
  String get internetMessage;
  String get dataFormatMessage;
  String get unKnownServerMessage;
  String get unKnownMessage;
  String get unauthorizedMessage;
}
