import 'package:admin_app/staff/shared/read_json.dart';

class StaffAttachment {
  const StaffAttachment({required this.name, required this.url});

  final String name;
  final String url;

  static StaffAttachment? tryFrom(dynamic raw) {
    if (raw is! Map) return null;
    final url = readString(raw['url'] ?? raw['download_url'] ?? raw['file']);
    final name = readString(raw['name'] ?? raw['file_name'] ?? raw['title']);
    if (url.isEmpty && name.isEmpty) return null;
    return StaffAttachment(name: name.isEmpty ? 'Attachment' : name, url: url);
  }
}

List<StaffAttachment> readAttachments(dynamic raw) {
  return [
    for (final item in objectList(raw))
      if (StaffAttachment.tryFrom(item) case final file?) file,
  ];
}
