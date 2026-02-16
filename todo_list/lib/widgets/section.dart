import 'package:flutter/material.dart';
import '../modelos/tarea.dart';

class Section extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  final Function(Task) onTap;
  final bool Function(Task) isLate;

  const Section({
    super.key,
    required this.title,
    required this.tasks,
    required this.onTap,
    required this.isLate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white54)),
        const SizedBox(height: 8),

        Expanded(
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final t = tasks[index];
              final late = isLate(t);

              return ListTile(
                title: Text(
                  '${t.title} (${t.time})',
                  style: TextStyle(
                    color: late
                        ? Colors.red
                        : (t.completed ? Colors.white38 : Colors.white70),
                    decoration:
                        t.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  t.description,
                  style: const TextStyle(color: Colors.white38),
                ),
                trailing: Icon(
                  t.completed
                      ? Icons.check
                      : Icons.radio_button_unchecked,
                  color: Colors.white54,
                ),
                onTap: () => onTap(t),
              );
            },
          ),
        ),
      ],
    );
  }
}
