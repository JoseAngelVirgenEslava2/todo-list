import 'package:flutter/material.dart';
import '../modelos/base_datos.dart';
import '../modelos/tarea.dart';


class CompletedTodayScreen extends StatelessWidget {
  const CompletedTodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terminadas hoy')),
      body: FutureBuilder<List<Task>>(
        future: AppDatabase.instance.getTasksCompletedToday(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!;
          if (tasks.isEmpty) {
            return const Center(child: Text('No hay tareas hoy'));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (_, i) => ListTile(
              title: Text(tasks[i].title),
              subtitle: Text(tasks[i].description),
            ),
          );
        },
      ),
    );
  }
}