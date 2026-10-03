// No material import needed

enum TaskPriority { high, medium, low }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final TaskPriority priority;
  final DateTime? dueDate;
  final String dueTime;
  final bool isCompleted;

  const TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.category = 'Other',
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.dueTime = '',
    this.isCompleted = false,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    TaskPriority? priority,
    DateTime? dueDate,
    String? dueTime,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory TaskModel.fromRow(Map<String, dynamic> row) {
    return TaskModel(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String? ?? '',
      category: row['category'] as String? ?? 'Other',
      priority: TaskPriority.values.asNameMap()[row['priority']] ??
          TaskPriority.medium,
      dueDate: row['due_date'] == null
          ? null
          : DateTime.parse(row['due_date'] as String).toLocal(),
      dueTime: row['due_time'] as String? ?? '',
      isCompleted: row['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toRow() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority.name,
      'due_date': dueDate?.toUtc().toIso8601String(),
      'due_time': dueTime,
      'is_completed': isCompleted,
    };
  }
}
