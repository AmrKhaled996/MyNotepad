
import 'package:hive_flutter/hive_flutter.dart';

import 'package:test_work_sapce/notes.dart';
import 'package:test_work_sapce/tasks.dart';


class HiveService {
  static final HiveService _instance = HiveService._internal();

  late Box<Notes> _notesBox;
  late Box<Tasks> _tasksBox;

  factory HiveService() => _instance;

  HiveService._internal(); //means  it is a private constructor 


  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(NotesAdapter());
    Hive.registerAdapter(TasksAdapter());
    Hive.registerAdapter(TaskAdapter());

    _notesBox = await Hive.openBox('notebox');
    _tasksBox = await Hive.openBox('taskbox');

  }



  List<Notes> getNotes() => _notesBox.values.toList();
 
  Future<void> addNote(Notes note) async => await _notesBox.put(note.id, note);
 
  Future<void> updateNote(Notes note) async {
  await _notesBox.delete(note.id);
  await _notesBox.put(note.id, note);

}
 
 
  Future<void> deleteNote(String id) async => await _notesBox.delete(id);
 
  List<Notes> searchNotes(String text) {
    final lowerText = text.toLowerCase();
    return _notesBox.values.where((note) =>
      note.title.toLowerCase().contains(lowerText)    ||
      note.tag.toLowerCase().contains(lowerText) 
    ).toList();
  }
 
 
  List<Tasks> getTasks() => _tasksBox.values.toList();

  Future<void> addTask(Tasks task) async => await _tasksBox.put(task.id, task);

  Future<void> updateTask(Tasks task) async {
  await _tasksBox.delete(task.id);
  await _tasksBox.put(task.id, task);

}

  Future<void> deleteTask(String id) async => await _tasksBox.delete(id);

  List<Tasks> searchTasks(String text) {

    final lowerText = text.toLowerCase();
    return _tasksBox.values.where((task) =>
      task.title.toLowerCase().contains(lowerText)    ||
      task.tag.toLowerCase().contains(lowerText) 
      
    ).toList();

  }
}