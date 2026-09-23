import 'package:admin_app/core/update/store_listing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const _updateColor = Color(0xFF1B447F);

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  Future<void> _openStore() async {
    try {
      var packageName = '';
      try {
        final info = await PackageInfo.fromPlatform();
        packageName = info.packageName;
      } catch (_) {
        packageName = '';
      }
      final url = storeListingUrl(
        platform: defaultTargetPlatform,
        packageName: packageName,
      );
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final short = constraints.maxHeight < 700;
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: short ? 32 : 48,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _UpdateAnimation(height: short ? 240 : 300),
                            const SizedBox(height: 24),
                            const Text(
                              'Update Required',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: _updateColor,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'A new version is available. Please update to continue.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _openStore,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: _updateColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: const Text(
                                  'Update',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _UpdateAnimation extends StatelessWidget {
  const _UpdateAnimation({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/Update-app.json',
      height: height,
      repeat: true,
      errorBuilder: (context, error, stackTrace) => const _UpdateFallback(),
    );
  }
}

class _UpdateFallback extends StatelessWidget {
  const _UpdateFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: _updateColor.withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.system_update_rounded,
        size: 80,
        color: _updateColor,
      ),
    );
  }
}
