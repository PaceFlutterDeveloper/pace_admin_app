import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showSnackbar(BuildContext context, String text) {
  final snackbar = SnackBar(
    content: Text(text),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}

showToast(String message) => Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    fontSize: 16.0);

int toDec(List<int> bytes) {
  int result = 0;
  int factor = 1;
  for (int i = 0; i < bytes.length; ++i) {
    int value = bytes[i] & 0xFF;
    result += value * factor;
    factor *= 256;
  }
  return result;
}
