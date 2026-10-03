import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/task_model.dart';
import '../models/goal_model.dart';
import '../models/savings_goal.dart';
import '../models/icon_registry.dart';
import '../services/supabase_service.dart';

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

  factory ListData.fromRow(Map<String, dynamic> row) {
    final items = List<String>.from(row['items'] as List? ?? const []);
    return ListData(
      id: row['id'] as String,
      title: row['title'] as String,
      icon: iconFromName(row['icon'] as String?,
          fallback: LucideIcons.shoppingCart),
      itemCnt: items.length,
      members: List<String>.from(row['members'] as List? ?? const ['A']),
      items: items,
    );
  }

  Map<String, dynamic> toRow() {
    return {
      'id': id,
      'title': title,
      'icon': iconToName(icon),
      'members': members,
      'items': items,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SYNC HELPERS — Local state updates first, then Supabase in the background.
// When Supabase isn't available, notifiers run on local sample data only.
// ─────────────────────────────────────────────────────────────────────────────

Future<List<Map<String, dynamic>>> _fetchRows(String table) {
  return SupabaseService.client
      .from(table)
      .select()
      .order('created_at', ascending: true);
}

/// Runs [op] against Supabase; on failure logs and re-syncs via [reload].
Future<void> _remote(
  Future<void> Function() op,
  Future<void> Function() reload,
) async {
  if (!SupabaseService.isReady) return;
  try {
    await op();
  } catch (e) {
    debugPrint('Supabase write failed, re-syncing: $e');
    await reload();
  }
}

class TasksNotifier extends StateNotifier<List<TaskModel>> {
  TasksNotifier() : super(SupabaseService.isReady ? const [] : _initialTasks) {
    if (SupabaseService.isReady) load();
  }

  static const _table = 'tasks';

  Future<void> load() async {
    try {
      final rows = await _fetchRows(_table);
      if (mounted) state = rows.map(TaskModel.fromRow).toList();
    } catch (e) {
      debugPrint('Failed to load tasks: $e');
    }
  }

  void addTask(TaskModel task) {
    state = [...state, task];
    _remote(() => SupabaseService.client.from(_table).insert(task.toRow()), load);
  }

  void toggleTaskCompletion(String id) {
    state = [
      for (final task in state)
        if (task.id == id)
          task.copyWith(isCompleted: !task.isCompleted)
        else
          task
    ];
    final task = state.firstWhere((t) => t.id == id);
    _remote(
      () => SupabaseService.client
          .from(_table)
          .update({'is_completed': task.isCompleted}).eq('id', id),
      load,
    );
  }

  void deleteTask(String id) {
    state = state.where((task) => task.id != id).toList();
    _remote(() => SupabaseService.client.from(_table).delete().eq('id', id), load);
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, List<TaskModel>>((ref) {
  return TasksNotifier();
});

class GoalsNotifier extends StateNotifier<List<GoalModel>> {
  GoalsNotifier() : super(SupabaseService.isReady ? const [] : _initialGoals) {
    if (SupabaseService.isReady) load();
  }

  static const _table = 'goals';

  Future<void> load() async {
    try {
      final rows = await _fetchRows(_table);
      if (mounted) state = rows.map(GoalModel.fromRow).toList();
    } catch (e) {
      debugPrint('Failed to load goals: $e');
    }
  }

  void addGoal(GoalModel goal) {
    state = [...state, goal];
    _remote(() => SupabaseService.client.from(_table).insert(goal.toRow()), load);
  }

  void updateGoalProgress(String id, double newProgress) {
    state = [
      for (final goal in state)
        if (goal.id == id)
          goal.copyWith(progress: newProgress)
        else
          goal
    ];
    _remote(
      () => SupabaseService.client
          .from(_table)
          .update({'progress': newProgress}).eq('id', id),
      load,
    );
  }

  void deleteGoal(String id) {
    state = state.where((goal) => goal.id != id).toList();
    _remote(() => SupabaseService.client.from(_table).delete().eq('id', id), load);
  }
}

final goalsProvider = StateNotifierProvider<GoalsNotifier, List<GoalModel>>((ref) {
  return GoalsNotifier();
});

class ListsNotifier extends StateNotifier<List<ListData>> {
  ListsNotifier() : super(SupabaseService.isReady ? const [] : _initialLists) {
    if (SupabaseService.isReady) load();
  }

  static const _table = 'lists';

  Future<void> load() async {
    try {
      final rows = await _fetchRows(_table);
      if (mounted) state = rows.map(ListData.fromRow).toList();
    } catch (e) {
      debugPrint('Failed to load lists: $e');
    }
  }

  void _save(String listId) {
    final list = state.firstWhere((l) => l.id == listId);
    final row = list.toRow()..remove('id');
    _remote(
      () => SupabaseService.client.from(_table).update(row).eq('id', listId),
      load,
    );
  }

  void addList(ListData list) {
    state = [...state, list];
    _remote(() => SupabaseService.client.from(_table).insert(list.toRow()), load);
  }

  void updateList(ListData updatedList) {
    state = [
      for (final list in state)
        if (list.id == updatedList.id) updatedList else list
    ];
    _save(updatedList.id);
  }

  void deleteList(String id) {
    state = state.where((list) => list.id != id).toList();
    _remote(() => SupabaseService.client.from(_table).delete().eq('id', id), load);
  }

  void updateListItems(String listId, List<String> items) {
    state = [
      for (final list in state)
        if (list.id == listId)
          list.copyWith(items: items, itemCnt: items.length)
        else
          list
    ];
    _save(listId);
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
    _save(listId);
  }
}

final listsProvider = StateNotifierProvider<ListsNotifier, List<ListData>>((ref) {
  return ListsNotifier();
});

class SavingsNotifier extends StateNotifier<List<SavingsGoal>> {
  SavingsNotifier() : super(_initialSavings);

  void add(SavingsGoal goal) => state = [...state, goal];

  void contribute(String id, double amount) {
    state = [
      for (final g in state)
        if (g.id == id)
          SavingsGoal(
            id: g.id,
            title: g.title,
            current: (g.current + amount).clamp(0, g.target),
            target: g.target,
            color: g.color,
            currency: g.currency,
            currencySymbol: g.currencySymbol,
          )
        else
          g
    ];
  }
}

final savingsProvider =
    StateNotifierProvider<SavingsNotifier, List<SavingsGoal>>((ref) => SavingsNotifier());

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
    progressColor: const Color(0xFF7A62D0), // Gentian
    category: 'Health',
    targetType: GoalTargetType.dailyHabit,
    progress: 1.0, 
    target: 1.0, 
  ),
  GoalModel(
    id: 'g2',
    title: 'Read 20 pages',
    icon: LucideIcons.book,
    progressColor: const Color(0xFFBB850E), // Larch
    category: 'Learning',
    targetType: GoalTargetType.dailyHabit,
    progress: 0.0, 
    target: 1.0, 
  ),
  GoalModel(
    id: 'g3',
    title: 'Run 5km',
    icon: LucideIcons.activity,
    progressColor: const Color(0xFFDB6840), // Alpenglow orange
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

final _initialSavings = <SavingsGoal>[
  SavingsGoal(
    id: 's1',
    title: 'Emergency Fund',
    current: 2500,
    target: 5000,
    color: const Color(0xFF7A62D0),
  ),
  SavingsGoal(
    id: 's2',
    title: 'Vacation',
    current: 800,
    target: 2000,
    color: const Color(0xFF1FA48A),
  ),
  SavingsGoal(
    id: 's3',
    title: 'New Laptop',
    current: 1500,
    target: 2400,
    color: const Color(0xFFBB850E),
  ),
];
