import 'package:flutter/material.dart';

class KeyboardManager {
  KeyboardManager._();

  static void unFocus(BuildContext context) {
    final node = FocusScope.of(context);
    if (node.hasFocus == false) return;
    node.unfocus();
  }
}
