import 'package:flutter/material.dart';

import 'icon_registry.dart';

enum GoalTargetType { numeric, yesNo, dailyHabit }

class GoalModel {
  final String id;
  final String title;
  final String category;
  final GoalTargetType targetType;
  final DateTime? deadline;
  final IconData icon;
  final Color progressColor;
  final double progress; 
  final double target;
  final String unit;

  const GoalModel({
    required this.id,
    required this.title,
    this.category = 'Personal',
    this.targetType = GoalTargetType.numeric,
    this.deadline,
    required this.icon,
    required this.progressColor,
    this.progress = 0.0,
    this.target = 100.0,
    this.unit = '',
  });

  GoalModel copyWith({
    String? id,
    String? title,
    String? category,
    GoalTargetType? targetType,
    DateTime? deadline,
    IconData? icon,
    Color? progressColor,
    double? progress,
    double? target,
    String? unit,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      targetType: targetType ?? this.targetType,
      deadline: deadline ?? this.deadline,
      icon: icon ?? this.icon,
      progressColor: progressColor ?? this.progressColor,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      unit: unit ?? this.unit,
    );
  }

  factory GoalModel.fromRow(Map<String, dynamic> row) {
    return GoalModel(
      id: row['id'] as String,
      title: row['title'] as String,
      category: row['category'] as String? ?? 'Personal',
      targetType: GoalTargetType.values.asNameMap()[row['target_type']] ??
          GoalTargetType.numeric,
      deadline: row['deadline'] == null
          ? null
          : DateTime.parse(row['deadline'] as String).toLocal(),
      icon: iconFromName(row['icon'] as String?),
      progressColor: Color((row['progress_color'] as num).toInt()),
      progress: (row['progress'] as num).toDouble(),
      target: (row['target'] as num).toDouble(),
      unit: row['unit'] as String? ?? '',
    );
  }

  Map<String, dynamic> toRow() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'target_type': targetType.name,
      'deadline': deadline?.toUtc().toIso8601String(),
      'icon': iconToName(icon),
      'progress_color': progressColor.toARGB32(),
      'progress': progress,
      'target': target,
      'unit': unit,
    };
  }
}
