import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/shared/staff_attachment.dart';

class StaffNotice {
  const StaffNotice({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.category,
    required this.publishedAt,
    required this.isRead,
    required this.isPinned,
    required this.hasAttachments,
    this.attachments = const [],
    this.needsAcknowledgement = false,
    this.acknowledged = false,
  });

  final String id;
  final String title;
  final String summary;
  final String body;
  final String category;
  final DateTime? publishedAt;
  final bool isRead;
  final bool isPinned;
  final bool hasAttachments;
  final List<StaffAttachment> attachments;
  final bool needsAcknowledgement;
  final bool acknowledged;

  StaffNotice copyWith({bool? isRead, bool? acknowledged}) {
    return StaffNotice(
      id: id,
      title: title,
      summary: summary,
      body: body,
      category: category,
      publishedAt: publishedAt,
      isRead: isRead ?? this.isRead,
      isPinned: isPinned,
      hasAttachments: hasAttachments,
      attachments: attachments,
      needsAcknowledgement: needsAcknowledgement,
      acknowledged: acknowledged ?? this.acknowledged,
    );
  }

  factory StaffNotice.fromMap(Map<String, dynamic> map) {
    final attachments = readAttachments(map['attachments']);
    return StaffNotice(
      id: readString(map['notice_id'] ?? map['id']),
      title: readString(map['title']),
      summary: readString(map['summary']),
      body: readString(map['body'] ?? map['content'] ?? map['description']),
      category: readString(map['category']),
      publishedAt: readDate(map['published_at'] ?? map['created_at']),
      isRead: readBool(map['is_read']),
      isPinned: readBool(map['is_pinned']),
      hasAttachments:
          readBool(map['has_attachments']) || attachments.isNotEmpty,
      attachments: attachments,
      needsAcknowledgement: readBool(
        map['requires_acknowledgement'] ?? map['needs_acknowledgement'],
      ),
      acknowledged: readBool(map['acknowledged'] ?? map['is_acknowledged']),
    );
  }
}
