import 'package:flutter/material.dart';
import '../../models/task.dart';
import 'cards.dart';

class TaskDraggableCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const TaskDraggableCard({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<TaskModel>(
      data: task,
      delay: const Duration(milliseconds: 200),
      feedback: Material(
        elevation: 12,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 280, // Match the width of the kanban column
          child: Opacity(
            opacity: 0.9,
            child: TaskCard(task: task, onTap: () {}),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: TaskCard(task: task, onTap: () {}),
      ),
      child: TaskCard(task: task, onTap: onTap),
    );
  }
}
