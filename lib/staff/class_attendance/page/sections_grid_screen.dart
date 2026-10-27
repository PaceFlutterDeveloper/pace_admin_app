import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/staff/class_attendance/model/grade_model.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void openClassRoll(
  BuildContext context, {
  required String grade,
  required String section,
  required String title,
}) {
  context.pushNamed(
    Routes.students.name,
    queryParameters: {'title': title, 'grade': grade, 'section': section},
  );
}

class SectionsGridScreen extends StatelessWidget {
  final GradeModel grade;

  const SectionsGridScreen({super.key, required this.grade});

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final sections = grade.sections;
    return StaffPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StaffPageHeader(
            title: grade.label,
            subtitle: sections.length == 1
                ? '1 section'
                : '${sections.length} sections',
          ),
          Expanded(
            child: sections.isEmpty
                ? const StaffStateMessage(
                    glyph: StaffGlyphs.users,
                    title: 'No sections',
                    message:
                        'This class has no sections to take attendance for.',
                    accent: StaffAccent.blue,
                  )
                : GridView.builder(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.05,
                        ),
                    itemCount: sections.length,
                    itemBuilder: (context, index) {
                      final section = sections[index];
                      return StaffCard(
                        radius: 20,
                        onTap: () => openClassRoll(
                          context,
                          grade: grade.gradeCode,
                          section: section,
                          title: '${grade.label} · $section',
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              section,
                              style: sora(
                                22,
                                weight: FontWeight.w800,
                                color: p.text,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Section',
                              style: sora(
                                11,
                                weight: FontWeight.w600,
                                color: p.muted,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
