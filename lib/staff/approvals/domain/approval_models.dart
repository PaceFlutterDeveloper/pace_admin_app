import 'package:admin_app/staff/shared/read_json.dart';

class StaffApproval {
  const StaffApproval({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    required this.requesterName,
    required this.requesterRole,
    required this.requesterPhoto,
    required this.submittedAt,
    required this.status,
    this.details = const [],
    this.comment = '',
  });

  final String id;
  final String type;
  final String title;
  final String summary;
  final String requesterName;
  final String requesterRole;
  final String requesterPhoto;
  final DateTime? submittedAt;
  final String status;

  /// Extra label/value rows the detail call returns (dates, balance, ...).
  final List<(String, String)> details;
  final String comment;

  bool get isPending => status.toLowerCase() == 'pending' || status.isEmpty;

  factory StaffApproval.fromMap(Map<String, dynamic> map) {
    final requester = map['requester'];
    return StaffApproval(
      id: readString(map['approval_id'] ?? map['id']),
      type: readString(map['type']),
      title: readString(map['title']),
      summary: readString(map['summary']),
      requesterName: requester is Map
          ? readString(requester['name'])
          : readString(requester),
      requesterRole: requester is Map
          ? readString(requester['designation'] ?? requester['role'])
          : '',
      requesterPhoto: requester is Map ? readString(requester['photo']) : '',
      submittedAt: readDate(map['submitted_at'] ?? map['created_at']),
      status: readString(map['status']),
      details: _details(map['details'] ?? map['detail'] ?? map['fields']),
      comment: readString(map['comment'] ?? map['decision_comment']),
    );
  }

  static List<(String, String)> _details(dynamic raw) {
    if (raw is Map) {
      return [
        for (final entry in raw.entries)
          if (readString(entry.value).isNotEmpty && entry.value is! Map)
            (_label(readString(entry.key)), readString(entry.value)),
      ];
    }
    if (raw is List) {
      return [
        for (final item in objectList(raw))
          if (readString(item['label'] ?? item['name']).isNotEmpty)
            (
              readString(item['label'] ?? item['name']),
              readString(item['value']),
            ),
      ];
    }
    return const [];
  }

  static String _label(String key) {
    final words = key.replaceAll('_', ' ').trim();
    if (words.isEmpty) return words;
    return words[0].toUpperCase() + words.substring(1);
  }
}

class ApprovalList {
  const ApprovalList({required this.items, required this.pending});

  final List<StaffApproval> items;
  final int pending;
}
