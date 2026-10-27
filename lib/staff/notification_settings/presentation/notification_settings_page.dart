import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/notification_settings/domain/notification_settings_models.dart';
import 'package:admin_app/staff/notification_settings/domain/notification_settings_repository.dart';
import 'package:admin_app/staff/shared/load_cubit.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_load_view.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Profile > Notification settings: push and in-app switches per category.
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({
    super.key,
    this.title = 'Notification settings',
  });

  final String title;

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late final NotificationSettingsRepository _repository =
      locator<NotificationSettingsRepository>();
  late final LoadCubit<NotificationSettings> _cubit = LoadCubit(
    _repository.load,
  )..load();

  /// Switches the person just changed, shown before the server confirms.
  final Map<String, NotificationCategory> _pending = {};

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _change(
    NotificationCategory category, {
    bool? push,
    bool? inApp,
  }) async {
    final next = category.copyWith(push: push, inApp: inApp);
    setState(() => _pending[category.key] = next);
    try {
      await _repository.update(
        category.key,
        push: next.push,
        inApp: next.inApp,
      );
      await _cubit.load(quiet: true);
      if (mounted) setState(() => _pending.remove(category.key));
    } catch (e) {
      if (!mounted) return;
      setState(() => _pending.remove(category.key));
      AppToast.error(context, staffErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: StaffPage(
        child: Column(
          children: [
            StaffPageHeader(
              title: widget.title,
              subtitle: 'Choose which alerts reach you',
            ),
            Expanded(
              child: StaffLoadView<NotificationSettings>(
                errorGlyph: StaffGlyphs.bell,
                errorTitle: 'Could not load settings',
                builder: (context, settings) {
                  if (settings.categories.isEmpty) {
                    return const StaffEmptyList(
                      glyph: StaffGlyphs.bell,
                      title: 'Nothing to set',
                      message: 'No alert categories are available for you.',
                    );
                  }
                  return ListView(
                    physics: staffScrollPhysics,
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    children: [
                      if (settings.hasQuietHours)
                        _Note(
                          'Quiet hours ${settings.quietFrom} – ${settings.quietTo}',
                        ),
                      for (final category in settings.categories)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _CategoryCard(
                            category: _pending[category.key] ?? category,
                            onPush: (v) => _change(category, push: v),
                            onInApp: (v) => _change(category, inApp: v),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(text, style: sora(12, color: p.muted)),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onPush,
    required this.onInApp,
  });

  final NotificationCategory category;
  final ValueChanged<bool> onPush;
  final ValueChanged<bool> onInApp;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return StaffCard(
      radius: 20,
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.label,
            style: sora(14, weight: FontWeight.w700, color: p.text),
          ),
          if (category.mandatory)
            Text('Required by your school', style: sora(11, color: p.muted)),
          const SizedBox(height: 4),
          _SwitchRow(
            label: 'Push notification',
            value: category.push,
            onChanged: category.mandatory ? null : onPush,
          ),
          _SwitchRow(
            label: 'In the app',
            value: category.inApp,
            onChanged: category.mandatory ? null : onInApp,
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Row(
      children: [
        Expanded(
          child: Text(label, style: sora(12.5, color: p.muted)),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: p.onAmber,
          activeTrackColor: p.amber,
        ),
      ],
    );
  }
}
