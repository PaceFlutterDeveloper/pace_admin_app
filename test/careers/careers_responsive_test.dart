import 'package:admin_app/careers/jobs/components/careers_job_card.dart';
import 'package:admin_app/careers/jobs/components/index.dart';
import 'package:admin_app/careers/jobs/components/job_card_skeleton.dart';
import 'package:admin_app/careers/jobs/models/job_model.dart';
import 'package:admin_app/careers/shared/components/index.dart';
import 'package:admin_app/careers/shared/theme/careers_theme.dart';
import 'package:admin_app/careers/user/components/profile_completion_button.dart';
import 'package:admin_app/careers/user/components/profile_header_card.dart';
import 'package:admin_app/careers/user/pages/complete_profile/widgets/profile_form_fields.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Smallest and largest phones we support.
const _sizes = <String, Size>{
  'small 360x640': Size(360, 640),
  'large 430x932': Size(430, 932),
};

final _job = JobModel(
  jobId: 1,
  title: 'Senior Secondary Mathematics and Further Mathematics Teacher',
  location: 'Al Quoz Industrial Area 3, Dubai, United Arab Emirates',
  schoolName: 'Pace International School of Science and Technology',
  country: 'United Arab Emirates',
  createdAt: '2026-09-01',
  deadline: '2026-12-31',
  description: '<p>Teach mathematics across key stages four and five.</p>',
  salary: SalaryInfo(range: 'AED 12,000 - 18,000', minYears: 5),
  employmentType: 'Full Time / Permanent',
  qualification: 'Bachelor of Education',
  requirements: 'Five years of classroom experience',
  status: 'open',
);

late ThemeData _theme;

void main() {
  final themes = <String, ThemeData>{
    'light': CareersTheme.light,
    'dark': CareersTheme.dark,
  };

  themes.forEach((themeLabel, theme) {
    group('$themeLabel theme', () {
      setUp(() => _theme = theme);
      _defineLayoutTests();
    });
  });
}

Future<void> _pumpAt(
  WidgetTester tester,
  Size size,
  Widget child, {

  /// Shimmer skeletons animate forever, so they cannot be settled.
  bool settle = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: _theme,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void _defineLayoutTests() {
  _sizes.forEach((label, size) {
    group('at $label', () {
      testWidgets('job card lays out without overflow', (tester) async {
        await _pumpAt(tester, size, CareersJobCard(job: _job));
      });

      testWidgets('job card skeleton lays out without overflow', (
        tester,
      ) async {
        await _pumpAt(tester, size, const JobCardSkeleton(), settle: false);
      });

      // The home tab puts this inside a SliverToBoxAdapter, so it must not
      // introduce a nested viewport.
      testWidgets('skeleton list lays out inside a sliver', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            theme: _theme,
            home: const Scaffold(
              body: CustomScrollView(
                slivers: [SliverToBoxAdapter(child: JobCardSkeletonList())],
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
      });

      // A Scaffold offers its bottom bar the full screen height, so the bar
      // must size itself to the CTA rather than stretching.
      testWidgets('apply bar stays the height of its button', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            theme: _theme,
            home: Scaffold(
              body: const SizedBox.expand(),
              bottomNavigationBar: ApplyBottomBar(job: _job),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final barHeight = tester.getSize(find.byType(ApplyBottomBar)).height;
        expect(barHeight, lessThan(120));
      });

      testWidgets('profile header lays out without overflow', (tester) async {
        await _pumpAt(
          tester,
          size,
          const ProfileHeaderCard(
            name: 'Abdulrahman Mohammed Al Suwaidi Al Maktoum',
            email: 'abdulrahman.almaktoum@paceschools.example.ae',
            isComplete: false,
            completionPercentage: 65,
          ),
        );
      });

      testWidgets('completion banner lays out without overflow', (
        tester,
      ) async {
        await _pumpAt(tester, size, const ProfileCompletionButton());
      });

      testWidgets('section card and info rows lay out without overflow', (
        tester,
      ) async {
        await _pumpAt(
          tester,
          size,
          const SectionCard(
            title: 'Overview',
            icon: CupertinoIcons.briefcase,
            child: Column(
              children: [
                InfoRow(
                  label: 'Preferred position',
                  value: 'Head of Mathematics Department, Secondary Campus',
                  icon: CupertinoIcons.briefcase,
                ),
              ],
            ),
          ),
        );
      });

      testWidgets('empty and error states lay out without overflow', (
        tester,
      ) async {
        await _pumpAt(
          tester,
          size,
          const Column(
            children: [
              CareersEmptyState(
                icon: CupertinoIcons.briefcase,
                title: 'No jobs found',
                message: 'Try adjusting your search or filters.',
                actionLabel: 'Clear filters',
              ),
              CareersErrorState(),
            ],
          ),
        );
      });

      testWidgets('auth scaffold lays out without overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            theme: _theme,
            home: CareersAuthScaffold(
              title: 'Welcome back',
              subtitle: 'Sign in to continue your job search.',
              form: Column(
                children: [
                  ProfileTextField(
                    label: 'Email',
                    controller: TextEditingController(),
                  ),
                  ProfileSwitchField(
                    label: 'Keep me signed in on this device',
                    value: true,
                    onChanged: (_) {},
                  ),
                ],
              ),
              footer: const [
                CareersAuthLink(
                  leading: "Don't have an account?",
                  action: 'Sign up',
                  onPressed: _noop,
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
      });
    });
  });
}

void _noop() {}
