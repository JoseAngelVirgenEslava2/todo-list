import '../widgets/section.dart';
import 'completed_today_screen.dart';
import 'pending_today_screen.dart';
import 'package:flutter/material.dart';
import '../modelos/tarea.dart';
import 'dart:async';
import '../modelos/base_datos.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  String phrase = '';
  String author = '';
  String currentTime =
    '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startClock();
  }

  void _startClock() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      setState(() {
        currentTime =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    //final loadedTasks = await AppDatabase.instance.getTasks();
    final randomPhrase = await AppDatabase.instance.getRandomPhrase();

    final completed = await AppDatabase.instance.getLatestCompletedTasks();
    final pending = await AppDatabase.instance.getClosestPendingTasks();

    setState(() {
      tasks = [...completed, ...pending];
      phrase = randomPhrase!.text;
      author = randomPhrase.author;
    });
  }

  Future<void> _showAddDialog() async {
    String title = '';
    String description = '';
    String start = '';
    String end = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva tarea'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                onChanged: (v) => title = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Descripción'),
                onChanged: (v) => description = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Inicio (20:00)'),
                onChanged: (v) => start = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Fin (21:30)'),
                onChanged: (v) => end = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (title.isNotEmpty && start.isNotEmpty && end.isNotEmpty) {
                await AppDatabase.instance.insertTask(Task(
                  title: title,
                  description: description,
                  time: '$start-$end',
                ));
                _loadData();
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleTask(Task task) async {

    if (task.completed) {
      return;
    }

    await AppDatabase.instance.updateTask(
      Task(
        id: task.id,
        title: task.title,
        description: task.description,
        time: task.time,
        completed: !task.completed,
        completedDate: DateTime.now().toIso8601String(),
      ),
    );
    _loadData();
  }

  bool _isLate(Task task) {
    if (task.completed) return false;

    final parts = task.time.split('-');
    if (parts.length != 2) return false;

    final endParts = parts[1].split(':');
    if (endParts.length != 2) return false;

    final now = DateTime.now();
    final endTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(endParts[0]),
      int.parse(endParts[1]),
    );

    return now.isAfter(endTime);
  }

  String titulo(String hora) {
    if (estaEnRango('04:00', '11:59', hora)) {
      return "Buen\ndia";
    } else if (estaEnRango('12:00', '18:59', hora)) {
      return "Buenas\ntardes";
    } else {
      return "Buenas\nnoches";
    }
  }


  List<double> generarRango(String rango) {
    if (rango.isNotEmpty) {
      String inicio = rango.split("-")[0];
      String ultimo = rango.split("-")[1];
      double num1;
      double num2;

      num1 = double.parse(inicio.replaceAll(":", "."));
      num2 = double.parse(ultimo.replaceAll(":", "."));
      return [num1, num2];
    }

    return [0,0];
  }

  int toMinutes(String hora) {
    final parts = hora.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  bool estaEnRango(String inicio, String fin, String actual) {
    final min = toMinutes(inicio);
    final max = toMinutes(fin);
    final target = toMinutes(actual);

    if (min <= max) {
      return target >= min && target <= max;
    } else {
      return target >= min || target <= max;
    }
  }


  Widget _buildPortraitLayout() {
  final completed = tasks.where((t) => t.completed).toList();
  final pending = tasks.where((t) => !t.completed).toList();

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            currentTime,
            style: const TextStyle(
              color: Color(0xFF3B82F6),
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 20),

        Text(
          titulo(currentTime),
          style: const TextStyle(
            color: Color(0xFF3B82F6),
            fontSize: 48,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),

        const SizedBox(height: 24),

        Text('"$phrase"', style: const TextStyle(color: Colors.white70)),
        Text('- $author',
            style: const TextStyle(
                color: Colors.white38, fontStyle: FontStyle.italic)),

        const SizedBox(height: 16),
        const Divider(color: Colors.white24),

        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CompletedTodayScreen()),
            ),
            child: Section(
              title: "Terminadas",
              tasks: completed,
              onTap: _toggleTask,
              isLate: _isLate,
            ),
          ),
        ),

        const Divider(color: Colors.white24),


        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PendingTodayScreen()),
            ),
            child: Section(
              title: 'Por terminar',
              tasks: pending,
              onTap: _toggleTask,
              isLate: _isLate,
            ),
          ),
        ),        
      ],
    ),
  );
}


  Widget _buildLandscapeLayout() {
  final completed = tasks.where((t) => t.completed).toList();
  final pending = tasks.where((t) => !t.completed).toList();

  return Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currentTime,
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                titulo(currentTime),
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Text('"$phrase"',
                  style: const TextStyle(color: Colors.white70)),
              Text('- $author',
                  style: const TextStyle(
                      color: Colors.white38,
                      fontStyle: FontStyle.italic)),
            ],
          ),
        ),

        const VerticalDivider(color: Colors.white24),

        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CompletedTodayScreen()),
                  ),
                  child: Section(
                    title: 'Terminadas',
                    tasks: completed,
                    onTap: _toggleTask,
                    isLate: _isLate,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PendingTodayScreen()),
                  ),
                  child: Section(
                    title: 'Por terminar',
                    tasks: pending,
                    onTap: _toggleTask,
                    isLate: _isLate,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
    backgroundColor: Colors.black,
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.transparent,
      elevation: 0,
      onPressed: _showAddDialog,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white54, width: 2),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    ),
    body: SafeArea(
      child: orientation == Orientation.portrait
          ? _buildPortraitLayout()
          : _buildLandscapeLayout(),
    ),
  );
  }
}