
class Task {
  final int? id;
  final String title;
  final String description;
  final bool completed;
  final String time;
  final String? completedDate;

  Task({this.id, required this.title, this.completed = false, required this.time, required this.description, this.completedDate});

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'completed': completed ? 1 : 0,
        'time': time,
        'description': description,
        'completedDate': completedDate
      };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'],
        title: map['title'],
        completed: map['completed'] == 1,
        time: map['time'],
        description: map['description'],
        completedDate: map['completedDate'],
      );
}


