import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Drops the current text focus and asks the platform to hide the keyboard.
///
/// Unfocus alone is not enough when the focused field is disposed with its
/// route: the engine can keep the keyboard up after the connection is gone.
void dismissKeyboard() {
  final focus = FocusManager.instance.primaryFocus;
  if (focus != null && focus.hasFocus) {
    focus.unfocus();
  }
  SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
}

/// Closes the keyboard when a route covers or removes a focused field.
///
/// Indexed stacks and pushed pages leave the previous [TextField] mounted.
/// Its connection stays open, so the keyboard remains on the next screen.
class DismissKeyboardNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    dismissKeyboard();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    dismissKeyboard();
  }
}
