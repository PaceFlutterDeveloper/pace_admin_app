import 'dart:convert';

import 'package:admin_app/staff/profile/components/document_section.dart';
import 'package:admin_app/staff/profile/document_share.dart';
import 'package:admin_app/staff/profile/model/doc_model.dart';
import 'package:admin_app/staff/profile/model/profile_data_model.dart';
import 'package:admin_app/staff/profile/personal_details.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('personal details use the profile payload and skip codes', () {
    final data = ProfileDataModel.fromMap(
      jsonDecode(_profile) as Map<String, dynamic>,
    );
    final lines = [
      for (final group in personalDetailGroups(data)) ...group.lines,
    ];
    final shown = {for (final line in lines) line.label: line.value};

    expect(shown['Full name'], 'Niyas Abdul Basheer');
    expect(shown.containsKey('Known as'), isFalse);
    expect(shown["Father's name"], 'Abdul Basheer');
    expect(shown["Mother's name"], 'Nabeesa Cherupanathadi');
    expect(shown['Gender'], 'Male');
    expect(shown['Date of birth'], '2 Dec 2001');
    expect(shown['Marital status'], 'Single');
    expect(shown['Employee ID'], '1965');
    expect(shown['Personal code'], '10002120123091');
    expect(shown['Designation'], 'Flutter Developer');
    expect(shown['Department'], 'Administration - IT Dept');
    expect(shown['Username'], 'niyas.a');
    expect(shown['Role'], 'Admin');
    expect(shown['Status'], 'Active');
    expect(shown['School'], 'Demo International School LLC');
    expect(shown['Joined'], '4 Dec 2025');
    expect(shown['Probation'], '3 months');
    expect(shown['Confirmed'], '4 Mar 2026');
    expect(shown['Visa type'], 'Employment');
    expect(shown['Yearly leave'], '45 days');
    expect(shown['Biometric ID'], '772');
    expect(shown['Personal email'], 'niyasx0011@gmail.com');
    expect(shown['School email'], 'niyas.a_pace@mypaceeducation.com');
    expect(shown['Area'], 'Airport Free Zone');
    expect(shown['Street'], 'Al Quisais 1');
    expect(shown['House'], '40/104-B Koladukkam, Cheerangamukku');
    expect(shown['Town'], 'Melmuri Post');
    expect(shown['City'], 'Malappuram, Kerala');
    expect(shown['Home mobile'], '+918714122834');
    expect(shown.containsKey('Home phone'), isFalse);
    expect(shown['Name'], 'Nawaz');
    expect(
      lines.where((line) => line.label == 'Mobile').map((line) => line.value),
      ['+971567948233', '+971543448789'],
    );
    expect(shown['Visa expiry'], '1 Jan 2027');
    expect(shown.containsKey('Passport'), isFalse);
    expect(lines.map((line) => line.value), isNot(contains('SECRET')));
    expect(lines.map((line) => line.value), isNot(contains('96')));
    expect(lines.map((line) => line.value), isNot(contains('32')));
    expect(lines.map((line) => line.label), isNot(contains('Salary')));
    expect(data.doc.single.downloadUrl, 'https://files.example/passport.pdf');
  });

  test('display text keeps acronyms and mixed-case words', () {
    expect(
      staffDisplayText('DEMO INTERNATIONAL SCHOOL LLC'),
      'Demo International School LLC',
    );
    expect(
      staffDisplayText('ADMINISTRATION - IT Dept'),
      'Administration - IT Dept',
    );
    expect(staffWord('admin'), 'Admin');
  });

  test('photo prefers a real portrait over placeholders', () {
    expect(
      profilePhotoUrl(
        rootPhoto: 'https://cdn.example/no_img.png',
        userPhoto: 'https://cdn.example/USER_PHOTOS/IMG/male.png',
        sessionPhoto: 'https://cdn.example/1965.jpg',
      ),
      'https://cdn.example/1965.jpg',
    );
  });

  test('document file name uses the title, number and extension', () {
    final doc = DocModel.fromMap({
      'id': '20176',
      'document': 'Health Insurance',
      'doc_no': 'LL1063835',
      'file_name': 'e25349_fb81b48ce3c11c18.jpg',
      'download_url': 'https://files.example/card.jpg',
    });
    expect(documentFileName(doc), 'Health_Insurance_LL1063835.jpg');
  });

  test('a signed-url error body is not treated as a file', () {
    final body = utf8.encode('{"status":false,"message":"Link expired"}');
    expect(
      staffDocumentBodyError(
        statusCode: 403,
        bytes: body,
        contentType: 'application/json',
      ),
      'Link expired',
    );
    expect(
      staffDocumentBodyError(
        statusCode: 200,
        bytes: utf8.encode('%PDF-1.4'),
        contentType: 'application/pdf',
      ),
      isNull,
    );
  });

  testWidgets('view and download use the document actions', (tester) async {
    DocModel? viewed;
    DocModel? shared;
    await tester.pumpWidget(
      _app(
        DocumentSection(
          documentStatus: 0,
          documents: [_passport(url: 'https://files.example/passport.pdf')],
          viewDocument: (_, doc) async => viewed = doc,
          shareDocument: (doc, {origin}) async => shared = doc,
        ),
      ),
    );
    expect(find.text('View'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);

    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
    expect(viewed?.id, '20176');

    await tester.tap(find.text('Download'));
    await tester.pumpAndSettle();
    expect(shared?.id, '20176');
  });

  testWidgets('download reports a failure', (tester) async {
    await tester.pumpWidget(
      _app(
        DocumentSection(
          documentStatus: 0,
          documents: [_passport(url: 'https://files.example/passport.pdf')],
          shareDocument: (doc, {origin}) async {
            throw const DocumentShareException('Link expired');
          },
        ),
      ),
    );
    await tester.tap(find.text('Download'));
    await tester.pumpAndSettle();
    expect(find.text('Link expired'), findsOneWidget);
  });

  testWidgets('hides actions when the document has no file link', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(DocumentSection(documentStatus: 0, documents: [_passport(url: '')])),
    );
    expect(find.text('View'), findsNothing);
    expect(find.text('Download'), findsNothing);
    expect(find.text('Issued 13 May 2022'), findsOneWidget);
    expect(find.text('Expires 12 May 2032'), findsOneWidget);
  });
}

Widget _app(Widget child) {
  return MaterialApp(
    theme: StaffTheme.light,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

DocModel _passport({required String url}) {
  return DocModel(
    id: '20176',
    doc: 'Passport',
    issueStat: '1',
    expiryStat: '1',
    alertDays: '30',
    stat: '1',
    alias: 'PP',
    docNo: 'V9227900',
    fileName: 'e20176.pdf',
    expiryDate: '2032-05-12',
    issueDate: '2022-05-13',
    downloadUrl: url,
  );
}

const _profile = '''
{
  "user": {
    "id": "755",
    "ad_username": "niyas.a",
    "name": "Niyas",
    "designation": "Flutter",
    "gender": "M",
    "title": "Mr.",
    "phone": "",
    "email": "",
    "emp_id": "1965",
    "role": "admin"
  },
  "school": {"name": "DEMO INTERNATIONAL SCHOOL LLC", "code": "100"},
  "photo": "https://cdn.example/no_img.png",
  "emp": {
    "empId": "1965",
    "personal_code": "10002120123091",
    "mr_ms": "Mr",
    "empl_name": "NIYAS ABDUL BASHEER",
    "designation": "FLUTTER DEVELOPER",
    "join_date": "2025-12-04",
    "prob": "3",
    "job_conf": "2026-03-04",
    "visa_type": "Employment",
    "visa_exp_date": "2027-01-01",
    "pp_no": "SECRET",
    "dob": "2001-12-02",
    "sex": "M",
    "mStatus": "Single",
    "local_emirate": "3",
    "local_region": "AIRPORT FREE ZONE",
    "local_street": "AL QUISAIS 1",
    "phone1": "+971567948233",
    "email": "niyasx0011@gmail.com",
    "per_house": "40/104-B KOLADUKKAM,CHEERANGAMUKKU",
    "per_town": "MELMURI POST",
    "per_city": "MALAPPURAM,KERALA",
    "per_country": "96",
    "per_tel_res": "+918714122834",
    "per_tel_mob": "+918714122834",
    "rel_name": "NAWAZ",
    "rel_tel_mob": "+971543448789",
    "stat": "Active",
    "school_email": "niyas.a_pace@mypaceeducation.com",
    "empl_fname": "ABDUL BASHEER",
    "empl_mname": "NABEESA CHERUPANATHADI",
    "nationality": "96",
    "yearly_leave": "45",
    "bank_id": "32",
    "sal_mode": "2",
    "religion": "0",
    "birth_counrty": "0",
    "biometric_id": "772",
    "department": "ADMINISTRATION - IT Dept"
  },
  "doc": [
    {
      "id": "20176",
      "document": "Passport",
      "alias": "PP",
      "doc_no": "V9227900",
      "file_name": "passport.pdf",
      "expiry_date": "2032-05-12",
      "issue_date": "2022-05-13",
      "download_url": "https://files.example/passport.pdf"
    }
  ],
  "alert": 0
}
''';
