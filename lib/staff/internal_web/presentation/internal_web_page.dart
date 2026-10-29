import 'package:admin_app/staff/home/models/menu_model.dart';
import 'package:admin_app/staff/home/utils/active_staff_user.dart';
import 'package:admin_app/staff/internal_web/internal_web_url.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Backend page opened from an internal-web menu item.
class InternalWebPage extends StatefulWidget {
  const InternalWebPage({super.key, required this.menu});

  final MenuModel menu;

  @override
  State<InternalWebPage> createState() => _InternalWebPageState();
}

class _InternalWebPageState extends State<InternalWebPage> {
  WebViewController? _controller;
  bool _loading = true;
  String? _error;
  String? _url;

  @override
  void initState() {
    super.initState();
    _url = _sessionUrl();
    if (_url == null) {
      _loading = false;
      _error = 'This page could not be opened.';
      return;
    }
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _loading = true;
              _error = null;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame != true || !mounted) return;
            setState(() {
              _loading = false;
              _error = 'This page could not be opened.';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_url!));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller?.setBackgroundColor(context.staff.background);
  }

  String? _sessionUrl() {
    final raw = widget.menu.webUrl?.trim() ?? '';
    if (!isHttpUrl(raw)) return null;
    final user = activeStaffUser();
    return staffInternalWebUrl(
      raw,
      token: user.token,
      adminId: user.userId,
      schoolCode: user.schoolCode,
    );
  }

  void _retry() {
    final url = _url;
    final controller = _controller;
    if (url == null || controller == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    controller.loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final title = internalWebLabel(widget.menu);
    return StaffPage(
      child: Column(
        children: [
          StaffPageHeader(title: title.isEmpty ? 'Page' : title),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    if (_controller != null && _error == null)
                      WebViewWidget(controller: _controller!),
                    if (_loading)
                      ColoredBox(
                        color: p.background,
                        child: Center(
                          child: CircularProgressIndicator(color: p.amberText),
                        ),
                      ),
                    if (_error != null)
                      ColoredBox(
                        color: p.background,
                        child: StaffStateMessage(
                          glyph: StaffGlyphs.globe,
                          title: 'Page unavailable',
                          message: _error,
                          actionLabel: _controller == null ? null : 'Try again',
                          onAction: _controller == null ? null : _retry,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
