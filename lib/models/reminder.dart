class Reminder {
  final int? id;
  final String userId;
  final String title;
  final String description;
  final String type; // 'medication', 'appointment', 'checkup', 'exercise', 'custom'
  final DateTime reminderDate;
  final String recurrenceType; // 'none', 'daily', 'weekly', 'monthly'
  final int? recurrenceInterval; // Every X days/weeks/months
  final bool isActive;
  final bool isCompleted;
  final DateTime? completedAt;
  final Map<String, dynamic> metadata; // Additional data based on type
  final DateTime createdAt;
  final DateTime updatedAt;

  Reminder({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.reminderDate,
    this.recurrenceType = 'none',
    this.recurrenceInterval,
    this.isActive = true,
    this.isCompleted = false,
    this.completedAt,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'type': type,
      'reminderDate': reminderDate.toIso8601String(),
      'recurrenceType': recurrenceType,
      'recurrenceInterval': recurrenceInterval,
      'isActive': isActive,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      type: map['type'],
      reminderDate: DateTime.parse(map['reminderDate']),
      recurrenceType: map['recurrenceType'] ?? 'none',
      recurrenceInterval: map['recurrenceInterval'],
      isActive: map['isActive'] ?? true,
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt'] != null 
          ? DateTime.parse(map['completedAt']) 
          : null,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Reminder copyWith({
    int? id,
    String? userId,
    String? title,
    String? description,
    String? type,
    DateTime? reminderDate,
    String? recurrenceType,
    int? recurrenceInterval,
    bool? isActive,
    bool? isCompleted,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      reminderDate: reminderDate ?? this.reminderDate,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if reminder is due
  bool isDue() {
    final now = DateTime.now();
    return reminderDate.isBefore(now) || 
           reminderDate.isAtSameMomentAs(now);
  }

  // Get next reminder date for recurring reminders
  DateTime? getNextReminderDate() {
    if (recurrenceType == 'none' || recurrenceInterval == null) {
      return null;
    }

    final interval = recurrenceInterval!;
    switch (recurrenceType) {
      case 'daily':
        return reminderDate.add(Duration(days: interval));
      case 'weekly':
        return reminderDate.add(Duration(days: 7 * interval));
      case 'monthly':
        final year = reminderDate.year;
        final month = reminderDate.month + interval;
        return DateTime(
          month > 12 ? year + (month - 1) ~/ 12 : year,
          month > 12 ? ((month - 1) % 12) + 1 : month,
          reminderDate.day,
          reminderDate.hour,
          reminderDate.minute,
        );
      default:
        return null;
    }
  }
}