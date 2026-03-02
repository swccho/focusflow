import 'package:equatable/equatable.dart';

/// Immutable domain entity for a focus-flow task.
final class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    required this.isDone,
    required this.createdAt,
    this.doneAt,
  });

  final String id;
  final String title;
  final bool isDone;
  final DateTime createdAt;
  final DateTime? doneAt;

  @override
  List<Object?> get props => [id, title, isDone, createdAt, doneAt];

  Task copyWith({
    String? id,
    String? title,
    bool? isDone,
    DateTime? createdAt,
    DateTime? doneAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      doneAt: doneAt ?? this.doneAt,
    );
  }
}
