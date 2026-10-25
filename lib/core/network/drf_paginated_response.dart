import 'package:equatable/equatable.dart';

/// Generic model wrapper for standard Django REST Framework (DRF) paginated responses.
/// Matches the DRF PageNumberPagination JSON envelope:
/// ```json
/// {
///   "count": 48,
///   "next": "http://.../api/v1/properties/?page=2",
///   "previous": null,
///   "results": [...]
/// }
/// ```
class DrfPaginatedResponse<T> extends Equatable {
  const DrfPaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory DrfPaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawResults = json['results'] as List<dynamic>? ?? [];
    return DrfPaginatedResponse<T>(
      count: json['count'] as int? ?? rawResults.length,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: rawResults
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  bool get hasNext => next != null && next!.isNotEmpty;
  bool get hasPrevious => previous != null && previous!.isNotEmpty;

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) => {
        'count': count,
        'next': next,
        'previous': previous,
        'results': results.map((item) => toJsonT(item)).toList(),
      };

  @override
  List<Object?> get props => [count, next, previous, results];
}
