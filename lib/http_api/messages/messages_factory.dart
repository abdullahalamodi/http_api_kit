import 'package:flutter/foundation.dart';

import '../http_api.dart';

class MessagesFactory {
  final String locale;

  MessagesFactory(this.locale);

  MessagesInterface get messages {
    switch (locale) {
      case 'en':
        return EnMessages();
      default:
        if (kDebugMode) {
          print('MessagesFactory----> This $locale not supported!');
        }
        throw UnsupportedError('this $locale not supported!');
    }
  }
}
