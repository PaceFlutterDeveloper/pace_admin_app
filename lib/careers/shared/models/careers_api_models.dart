/// Shared response primitives for PACE Careers API v2.
class CareersPagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNext;
  final bool hasPrev;

  const CareersPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNext,
    required this.hasPrev,
  });

  factory CareersPagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CareersPagination(
        currentPage: 1,
        totalPages: 1,
        totalItems: 0,
        itemsPerPage: 20,
        hasNext: false,
        hasPrev: false,
      );
    }

    final currentPage = json['current_page'] ?? 1;
    final totalPages = json['total_pages'] ?? 1;
    final totalItems =
        json['total_items'] ?? json['total_count'] ?? json['total'] ?? 0;
    final itemsPerPage =
        json['items_per_page'] ?? json['per_page'] ?? json['limit'] ?? 20;

    return CareersPagination(
      currentPage: currentPage is int
          ? currentPage
          : int.tryParse(currentPage.toString()) ?? 1,
      totalPages: totalPages is int
          ? totalPages
          : int.tryParse(totalPages.toString()) ?? 1,
      totalItems: totalItems is int
          ? totalItems
          : int.tryParse(totalItems.toString()) ?? 0,
      itemsPerPage: itemsPerPage is int
          ? itemsPerPage
          : int.tryParse(itemsPerPage.toString()) ?? 20,
      hasNext: json['has_next'] == true || json['has_next'] == 1,
      hasPrev: json['has_prev'] == true || json['has_prev'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'total_pages': totalPages,
    'total_items': totalItems,
    'items_per_page': itemsPerPage,
    'has_next': hasNext,
    'has_prev': hasPrev,
  };
}

/// Extracts a human-readable message from a Careers API error envelope.
String careersApiErrorMessage(Map<String, dynamic> json) {
  final message = json['message'];
  if (message != null && message.toString().trim().isNotEmpty) {
    return message.toString();
  }
  final error = json['error'];
  if (error != null && error.toString().trim().isNotEmpty) {
    return error.toString();
  }
  return 'Unknown API error';
}
