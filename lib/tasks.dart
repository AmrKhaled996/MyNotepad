import 'package:hive/hive.dart';

part "tasks.g.dart";

class Task {
  late String content;
  late bool completed;

  Task({
     required this.content,
    this.completed = false,
  });
}

@HiveType(typeId: 1)
class Tasks {
  @HiveField(0)
  int? id;

  static int idGene = 0;

  @HiveField(1)
  late final String title;
  @HiveField(2)
  final List<Task> tasks;
  @HiveField(3)
  final String tag;


  Tasks({
    int? id,
    required this.title,
    required this.tasks,
    required this.tag,
    
  }) : id = id ?? idGene++;
}
