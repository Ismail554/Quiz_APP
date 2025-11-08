class SelectTimeModel {
  final String id;
  final int duration;

  SelectTimeModel({
    required this.id,
    required this.duration,
  });

  factory SelectTimeModel.fromJson(Map<String, dynamic> json) {
    return SelectTimeModel(
      id: json['id'] ?? '',
      duration: json['duration'] ?? 0,
    );
  }
}

class SelectTimeResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<SelectTimeModel> results;

  SelectTimeResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory SelectTimeResponse.fromJson(Map<String, dynamic> json) {
    return SelectTimeResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => SelectTimeModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
