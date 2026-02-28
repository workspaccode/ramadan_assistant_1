class UmrahTrip {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final String status; // 'in_progress', 'completed'

  UmrahTrip({
    required this.id,
    required this.startDate,
    this.endDate,
    required this.status,
  });

  factory UmrahTrip.fromJson(Map<String, dynamic> json) {
    return UmrahTrip(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status,
    };
  }

  UmrahTrip copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) {
    return UmrahTrip(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
    );
  }
}
