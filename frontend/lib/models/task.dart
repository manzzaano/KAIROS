class Task {
  final String id;
  final String title;
  final int priority;
  final int energy;
  final int estimatedMinutes;
  final bool completed;
  final bool abandoned;
  final DateTime? completedAt;
  final DateTime? abandonedAt;
  final double? latitude;
  final double? longitude;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    required this.energy,
    this.estimatedMinutes = 0,
    this.completed = false,
    this.abandoned = false,
    this.completedAt,
    this.abandonedAt,
    this.latitude,
    this.longitude,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'].toString(),
        title: json['title'] as String,
        priority: json['priority'] as int,
        energy: json['energy'] as int,
        estimatedMinutes: json['estimated_minutes'] as int? ?? 0,
        completed: json['completed'] as bool? ?? false,
        abandoned: json['abandoned'] as bool? ?? false,
        completedAt: json['completed_at'] != null
            ? DateTime.tryParse(json['completed_at'] as String)
            : null,
        abandonedAt: json['abandoned_at'] != null
            ? DateTime.tryParse(json['abandoned_at'] as String)
            : null,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'priority': priority,
        'energy': energy,
        'estimated_minutes': estimatedMinutes,
        'completed': completed,
        'abandoned': abandoned,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

  Task copyWith({
    String? title,
    int? priority,
    int? energy,
    int? estimatedMinutes,
    bool? completed,
    bool? abandoned,
    DateTime? completedAt,
    DateTime? abandonedAt,
    double? latitude,
    double? longitude,
  }) =>
      Task(
        id: id,
        title: title ?? this.title,
        priority: priority ?? this.priority,
        energy: energy ?? this.energy,
        estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
        completed: completed ?? this.completed,
        abandoned: abandoned ?? this.abandoned,
        completedAt: completedAt ?? this.completedAt,
        abandonedAt: abandonedAt ?? this.abandonedAt,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );
}
