// The starter's data: a small task list saved on the device. Kept apart from the screens so it is
// easy to test and easy to swap for a real database or API later.
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Task {
  const Task({
    required this.id,
    required this.title,
    this.done = false,
    required this.createdAt,
    this.doneAt,
  });

  final String id;
  final String title;
  final bool done;
  final DateTime createdAt;
  final DateTime? doneAt;

  Task toggled(DateTime now) => Task(
    id: id,
    title: title,
    done: !done,
    createdAt: createdAt,
    doneAt: done ? null : now,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'done': done,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'doneAt': doneAt?.millisecondsSinceEpoch,
  };

  factory Task.fromJson(Map<String, Object?> j) => Task(
    id: j['id']! as String,
    title: j['title']! as String,
    done: j['done'] as bool? ?? false,
    createdAt: DateTime.fromMillisecondsSinceEpoch(j['createdAt']! as int),
    doneAt: j['doneAt'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(j['doneAt']! as int),
  );
}

enum Filter { all, open, done }

List<Task> sampleTasks(DateTime now) => [
  Task(
    id: 't1',
    title: 'Read the README and run the app',
    done: true,
    createdAt: now,
    doneAt: now,
  ),
  Task(
    id: 't2',
    title: 'Build the first screen from design/pages/',
    createdAt: now,
  ),
  Task(
    id: 't3',
    title: 'Replace this task list with your own data',
    createdAt: now,
  ),
];

/// Holds the tasks and the person's name, saves every change, and tells the screens to redraw.
class AppState extends ChangeNotifier {
  AppState(this._prefs) {
    final raw = _prefs.getString(_tasksKey);
    _tasks = raw == null
        ? sampleTasks(DateTime.now())
        : (jsonDecode(raw) as List<dynamic>)
              .map((t) => Task.fromJson(t as Map<String, Object?>))
              .toList();
    _name = _prefs.getString(_nameKey) ?? '';
  }

  static const _tasksKey = 'studio-starter:tasks';
  static const _nameKey = 'studio-starter:name';
  final SharedPreferences _prefs;
  late List<Task> _tasks;
  late String _name;

  List<Task> get tasks => List.unmodifiable(_tasks);
  String get name => _name;
  int get open => _tasks.where((t) => !t.done).length;
  int get total => _tasks.length;
  int doneToday(DateTime now) => _tasks
      .where(
        (t) =>
            t.done && t.doneAt != null && DateUtils.isSameDay(t.doneAt!, now),
      )
      .length;

  List<Task> filtered(Filter f) => switch (f) {
    Filter.all => tasks,
    Filter.open => _tasks.where((t) => !t.done).toList(),
    Filter.done => _tasks.where((t) => t.done).toList(),
  };

  void add(String title) {
    final clean = title.trim();
    if (clean.isEmpty) return;
    final now = DateTime.now();
    _tasks = [
      Task(
        id: now.microsecondsSinceEpoch.toString(),
        title: clean,
        createdAt: now,
      ),
      ..._tasks,
    ];
    _save();
  }

  void toggle(String id) {
    _tasks = [
      for (final t in _tasks) t.id == id ? t.toggled(DateTime.now()) : t,
    ];
    _save();
  }

  void remove(String id) {
    _tasks = _tasks.where((t) => t.id != id).toList();
    _save();
  }

  void reset() {
    _tasks = sampleTasks(DateTime.now());
    _save();
  }

  set name(String value) {
    _name = value;
    _prefs.setString(_nameKey, value);
    notifyListeners();
  }

  void _save() {
    _prefs.setString(
      _tasksKey,
      jsonEncode(_tasks.map((t) => t.toJson()).toList()),
    );
    notifyListeners();
  }
}

/// DateUtils without importing Material into the data layer.
abstract final class DateUtils {
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
