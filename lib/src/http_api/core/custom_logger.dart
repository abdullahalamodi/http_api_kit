import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

const _enableTagLogger = true;

final talker = TalkerFlutter.init();

@Deprecated('Use openLogger instead.')
void openLoger(BuildContext context) {
  openLogger(context);
}

void openLogger(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => TalkerScreen(talker: talker),
  ));
}

class CustomLogger {
  static void tagLogger({required String tag, required dynamic data}) {
    if (kDebugMode && _enableTagLogger) {
      talker.info(data);
    }
  }
}
