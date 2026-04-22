class Task {
  final String id;
  final String title;
  final int priority;
  final int energy;
  final bool completed;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    required this.energy,
    this.completed = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        priority: json['priority'] as int,
        energy: json['energy'] as int,
        completed: json['completed'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'priority': priority,
        'energy': energy,
        'completed': completed,
      };

  Task copyWith({
    String? title,
    int? priority,
    int? energy,
    bool? completed,
  }) =>
      Task(
        id: id,
        title: title ?? this.title,
        priority: priority ?? this.priority,
        energy: energy ?? this.energy,
        completed: completed ?? this.completed,
      );
}
