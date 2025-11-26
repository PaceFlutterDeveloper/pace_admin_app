import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HtmlNotificationIcon extends StatefulWidget {
  const HtmlNotificationIcon({Key? key}) : super(key: key);

  @override
  _HtmlNotificationIconState createState() => _HtmlNotificationIconState();
}

class _HtmlNotificationIconState extends State<HtmlNotificationIcon> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    // Initialize the WebViewController
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.dataFromString(
        _htmlContent,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ));
  }

  // Your HTML content as a string with centered styling
  final String _htmlContent = '''
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
          <style>
              body, html {
                  display: flex;
                  justify-content: center;
                  align-items: center;
                  height: 100%;
                  margin: 0;
                  background-color: transparent;
              }
              i {
                  font-size: 24px; /* Icon size */
                  color: #4e0bbb; /* Icon color */
              }
          </style>
      </head>
      <body>
          <i class="fa fa-user"></i> <!-- Font Awesome icon -->
      </body>
      </html>
  ''';

  @override
  Widget build(BuildContext context) {
    // Constrain WebView size to fit within the CircleAvatar
    return SizedBox(
      width: 48, // Match this size to fit within CircleAvatar radius
      height: 48,
      child: WebViewWidget(controller: controller),
    );
  }
}
