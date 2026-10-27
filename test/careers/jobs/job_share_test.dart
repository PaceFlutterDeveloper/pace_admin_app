import 'package:admin_app/careers/jobs/models/job_model.dart';
import 'package:admin_app/careers/jobs/utils/job_share.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('share text includes a job glimpse and the apply link', () {
    final message = JobShare.message(
      JobModel(
        jobId: 137,
        title: 'FS2 HOMEROOM TEACHER',
        location: 'Abu dhabi',
        schoolName: 'Creative British School LLC',
        country: 'United Arab Emirates',
        createdAt: '11/10/2026',
        deadline: '31/10/2026',
        description:
            '<p>Please note the position is for maternity cover period from Jan 2027.</p>',
        employmentType: 'Part-time',
        qualification:
            'Bachelor of Education,Valid teaching license in the subject.',
      ),
    );

    expect(message, contains('FS2 HOMEROOM TEACHER'));
    expect(message, contains('Creative British School LLC'));
    expect(message, contains('Abu dhabi, United Arab Emirates'));
    expect(message, contains('Part-time'));
    expect(message, contains('Apply by 31 Oct 2026'));
    expect(
      message,
      contains(
        'Please note the position is for maternity cover period from Jan 2027.',
      ),
    );
    expect(message, isNot(contains('<p>')));
    expect(message, contains('Qualification: Bachelor of Education'));
    expect(message, isNot(contains('Salary:')));
    expect(
      message,
      contains('https://paceeducation.com/careers/index.php?page=job&id=137'),
    );
    expect(
      message.indexOf('FS2 HOMEROOM TEACHER'),
      lessThan(message.indexOf('https://')),
    );
  });

  test('share text includes salary and experience when the job has them', () {
    final message = JobShare.message(
      JobModel(
        jobId: 130,
        title: 'Bus Driver',
        location: 'Dubai',
        schoolName: 'Pace School',
        createdAt: '01/10/2026',
        deadline: '',
        description: 'Safely transporting students.',
        salary: SalaryInfo(range: '2000-2500', minYears: 1, maxYears: 2),
        employmentType: 'Full-time',
      ),
    );

    expect(message, contains('Full-time · Salary: AED 2000-2500 · 1–2 years'));
    expect(message, contains('Safely transporting students.'));
    expect(message, isNot(contains('Apply by')));
  });
}
