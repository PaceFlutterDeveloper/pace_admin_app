import 'package:admin_app/staff/reports/domain/report_models.dart';

abstract class ReportsRepository {
  Future<List<ReportInfo>> available();

  Future<ReportResult> run(
    String key, {
    required DateTime from,
    required DateTime to,
  });
}
