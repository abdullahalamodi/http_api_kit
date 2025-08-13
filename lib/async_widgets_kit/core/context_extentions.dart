import 'package:flutter/material.dart';

extension ContextExtentions on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
}
