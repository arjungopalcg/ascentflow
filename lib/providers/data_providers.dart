import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../models/task_model.dart';
import '../models/goal_model.dart';

class ListData {
  final String id;
  final String title;
  final IconData icon;
  final int itemCnt;
  final List<String> members;
  final List<String> items;

  ListData({
    required this.id,
    required this.title,
    required this.icon,
    this.itemCnt = 0,
    this.members = const ['A'],
    this.items = const [],
  });

  ListData copyWith({
    String? title,
    IconData? icon,
    int? itemCnt,
    List<String>? members,
    List<String>? items,
  }) {
    return ListData(
      id: id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      itemCnt: itemCnt ?? this.itemCnt,
      members: members ?? this.members,
      items: items ?? this.items,
    );
  }
}

class TasksNotifier extends StateNotifier<List<TaskModel>> {
  TasksNotifier() : super(_initialTasks);

  void addTask(TaskModel task) {
    state = [...state, task];
  }

  void toggleTaskCompletion(String id) {
    state = [
      for (final task in state)
        if (task.id == id)
          task.copyWith(isCompleted: !task.isCompleted)
        else
          task
    ];
  }

  void deleteTask(String id) {
    state = state.where((task) => task.id != id).toList();
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, List<TaskModel>>((ref) {
  return TasksNotifier();
});

class GoalsNotifier extends StateNotifier<List<GoalModel>> {
  GoalsNotifier() : super(_initialGoals);

  void addGoal(GoalModel goal) {
    state = [...state, goal];
  }

  void updateGoalProgress(String id, double newProgress) {
    state = [
      for (final goal in state)
        if (goal.id == id)
          goal.copyWith(progress: newProgress)
        else
          goal
    ];
  }

  void deleteGoal(String id) {
    state = state.where((goal) => goal.id != id).toList();
  }
}

final goalsProvider = StateNotifierProvider<GoalsNotifier, List<GoalModel>>((ref) {
  return GoalsNotifier();
});

class ListsNotifier extends StateNotifier<List<ListData>> {
  ListsNotifier() : super(_initialLists);

  void addList(ListData list) {
    state = [...state, list];
  }

  void updateList(ListData updatedList) {
    state = [
      for (final list in state)
        if (list.id == updatedList.id) updatedList else list
    ];
  }

  void deleteList(String id) {
    state = state.where((list) => list.id != id).toList();
  }

  void updateListItems(String listId, List<String> items) {
    state = [
      for (final list in state)
        if (list.id == listId)
          list.copyWith(items: items, itemCnt: items.length)
        else
          list
    ];
  }

  void addMember(String listId, String initial) {
    state = [
      for (final list in state)
        if (list.id == listId)
          list.copyWith(
            members: list.members.contains(initial)
                ? list.members
                : [...list.members, initial],
          )
        else
          list
    ];
  }
}

final listsProvider = StateNotifierProvider<ListsNotifier, List<ListData>>((ref) {
  return ListsNotifier();
});

// Mock Initial Data
final _initialTasks = [
  TaskModel(
    id: 't1',
    title: 'Review Q1 strategy deck',
    category: 'Work',
    priority: TaskPriority.high,
    dueDate: DateTime.now(),
    dueTime: '10:00 AM',
  ),
  TaskModel(
    id: 't2',
    title: 'Schedule dentist appointment',
    category: 'Personal',
    priority: TaskPriority.medium,
    dueTime: 'Tomorrow',
  ),
  TaskModel(
    id: 't3',
    title: 'Buy groceries',
    category: 'Shopping',
    priority: TaskPriority.low,
    isCompleted: true,
  ),
];

final _initialGoals = [
  GoalModel(
    id: 'g1',
    title: 'Morning Meditation',
    icon: LucideIcons.moon,
    progressColor: const Color(0xFF9E77F1), // Primary
    category: 'Health',
    targetType: GoalTargetType.dailyHabit,
    progress: 1.0, 
    target: 1.0, 
  ),
  GoalModel(
    id: 'g2',
    title: 'Read 20 pages',
    icon: LucideIcons.book,
    progressColor: const Color(0xFFFFB053), // Sunset
    category: 'Learning',
    targetType: GoalTargetType.dailyHabit,
    progress: 0.0, 
    target: 1.0, 
  ),
  GoalModel(
    id: 'g3',
    title: 'Run 5km',
    icon: LucideIcons.activity,
    progressColor: const Color(0xFF63C2A5), // Mint
    category: 'Health',
    targetType: GoalTargetType.numeric,
    progress: 2.5,
    target: 5.0,
    unit: 'km',
  ),
];

final _initialLists = [
  ListData(
    id: 'l1',
    title: 'Grocery List',
    icon: LucideIcons.shoppingCart,
    itemCnt: 12,
    members: ['A', 'S'],
    items: ['Milk', 'Eggs', 'Bread', 'Apples', 'Pasta'],
  ),
  ListData(
    id: 'l2',
    title: 'Reading List',
    icon: LucideIcons.bookOpen,
    itemCnt: 24,
    members: ['A', 'M'],
    items: ['Atomic Habits', 'Deep Work', 'The Almanack'],
  ),
  ListData(
    id: 'l3',
    title: 'Bucket List',
    icon: LucideIcons.map,
    itemCnt: 8,
    members: ['A'],
  ),
  ListData(
    id: 'l4',
    title: 'Gift Ideas',
    icon: LucideIcons.gift,
    itemCnt: 4,
    members: ['A'],
  ),
];
