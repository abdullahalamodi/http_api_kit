// ignore_for_file: public_member_api_docs, sort_constructors_first

class PaginationModel {
  final int currentPage;
  final int? nextPage;
  final int? previousPage;
  final int totalPages;
  final int? perPage;
  final int totalEntries;

  PaginationModel({
    required this.currentPage,
    required this.nextPage,
    required this.previousPage,
    required this.totalPages,
    required this.perPage,
    required this.totalEntries,
  });

  PaginationModel copyWith({
    int? currentPage,
    int? nextPage,
    int? previousPage,
    int? totalPages,
    int? perPage,
    int? totalEntries,
  }) {
    return PaginationModel(
      currentPage: currentPage ?? this.currentPage,
      nextPage: nextPage ?? this.nextPage,
      previousPage: previousPage ?? this.previousPage,
      totalPages: totalPages ?? this.totalPages,
      perPage: perPage ?? this.perPage,
      totalEntries: totalEntries ?? this.totalEntries,
    );
  }

  @override
  String toString() {
    return 'PaginationModel(currentPage: $currentPage, nextPage: $nextPage, previousPage: $previousPage, totalPages: $totalPages, perPage: $perPage, totalEntries: $totalEntries)';
  }

  @override
  bool operator ==(covariant PaginationModel other) {
    if (identical(this, other)) return true;

    return other.currentPage == currentPage &&
        other.nextPage == nextPage &&
        other.previousPage == previousPage &&
        other.totalPages == totalPages &&
        other.perPage == perPage &&
        other.totalEntries == totalEntries;
  }

  @override
  int get hashCode {
    return currentPage.hashCode ^
        nextPage.hashCode ^
        previousPage.hashCode ^
        totalPages.hashCode ^
        perPage.hashCode ^
        totalEntries.hashCode;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'current_page': currentPage,
      'next_page': nextPage,
      'previous_page': previousPage,
      'total_pages': totalPages,
      'per_page': perPage,
      'total_entries': totalEntries,
    };
  }

  factory PaginationModel.fromJson(Map<String, dynamic> map) {
    return PaginationModel(
      currentPage: map['current_page'] as int,
      nextPage: map['next_page'] != null ? map['next_page'] as int : null,
      previousPage: map['previous_page'] != null ? map['previous_page'] as int : null,
      totalPages: map['total_pages'] as int,
      perPage: map['per_page'] != null ? map['per_page'] as int : null,
      totalEntries: map['total_entries'] as int,
    );
  }
}
