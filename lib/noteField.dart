import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:test_work_sapce/hiveDatabase.dart';
// import 'package:test_work_sapce/TagsInput.dart';

import 'package:test_work_sapce/notes.dart';
import 'package:test_work_sapce/tasks.dart';

// ignore: must_be_immutable
class Notefield extends StatefulWidget {
  Notefield(
      {super.key, this.isUpdate, this.existingNote, this.existingTODOlist});

  bool? isUpdate = false;
  Notes? existingNote;
  Tasks? existingTODOlist;

  @override
  State<Notefield> createState() => NotefieldState();
}

class NotefieldState extends State<Notefield> {
  HiveService hiveS = HiveService();

  Box<Notes> _notesBox = Hive.box('noteBox');
  Box<Tasks> _tasksBox = Hive.box('taskBox');

  List<Task> tasks = []; // List to store tasks

  List<String> newTasks = []; // Variable to store new task input

  bool? isChecked = false;

  late final TextEditingController _titleController = TextEditingController();
  late final TextEditingController _contentController = TextEditingController();

  int existingNoteId = 0;
  int existingTODOlistId = 0;

  @override
  void initState() {
    super.initState();
    if (widget.existingNote != null) {
      existingNoteId = widget.existingNote?.id ?? 0;
      _titleController.text = widget.existingNote?.title ?? "";
      _contentController.text = widget.existingNote?.content ?? "";
      selectedTag = widget.existingNote?.tag ?? "";
    }
    if (widget.existingTODOlist != null) {
      existingTODOlistId = widget.existingTODOlist?.id ?? 0;
      _titleController.text = widget.existingTODOlist?.title ?? "";
      tasks = widget.existingTODOlist?.tasks ?? [];
      selectedTag = widget.existingTODOlist?.tag ?? "";
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  TextEditingController tagsController = TextEditingController();
  String selectedTag = ''; // To store selected tags

  @override
  Widget build(BuildContext context) {
    Widget buildTagsInput() {
      return Container(
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                hint: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment(-0.95, 0),
                  child: Text(
                    "Select Tag",
                    style: TextStyle(
                      color: const Color.fromARGB(53, 0, 0, 0),
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                isExpanded: true,
                value: selectedTag.isEmpty ? null : selectedTag,
                dropdownColor: Colors.white,
                icon: const Icon(Icons.arrow_drop_down),
                style: TextStyle(color: Colors.black, fontSize: 20),
                underline: Container(
                  padding: const EdgeInsets.only(top: 35),
                  height: 0.8,
                  color: const Color.fromARGB(
                      255, 0, 0, 0), // Set the color of the underline
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Shopping',
                    child: Text(
                      'Shopping',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Tasks',
                    child: Text(
                      'Tasks',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Dairy',
                    child: Text(
                      'Dairy',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Note',
                    child: Text(
                      'Note',
                    ),
                  ),
                ],
                onChanged: (String? value) {
                  setState(() {
                    selectedTag = value!;
                    tagsController.text = selectedTag;
                  });
                },
              ),
            ),
          ],
        ),
      );
    }

    Widget buildToDoListInput() {
      // Initialize the checkbox value

      return Expanded(
          child: Container(
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 10, left: 15),
                hintText: 'Add Task',
                hintStyle: TextStyle(
                  color: const Color.fromARGB(53, 0, 0, 0),
                  fontSize: 20,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    if (_contentController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill the task field')),
                      );
                    } else {
                      setState(() {
                        String task = _contentController.text;
                        Task newTask = Task(
                          content: task,
                          completed: false,
                        );
                        tasks.add(newTask);
                        _contentController
                            .clear(); // Clear the text field after adding
                      });
                    }
                  },
                  icon: Icon(
                    Icons.add,
                    size: 40,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Container(
              height: 300,
              width: double.infinity,
              // color: Colors.red,

              child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Row(children: [
                      Checkbox(
                        value: tasks[index].completed,
                        activeColor: Colors.blue[400],
                        onChanged: (bool? value) {
                          setState(() {
                            tasks[index].completed = value!;
                          });
                        },
                      ),
                      Container(
                        alignment: Alignment(-1, 0),
                        child: Text(tasks[index].content,
                            style: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontSize: 20,
                            )),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 50),
                        alignment: Alignment(-1, 0),
                        child: IconButton(
                            onPressed: () {
                              setState(() {
                                tasks.removeAt(index);
                              });
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 30,
                            )),
                      ),
                    ]);
                  }),
            ),
          ],
        ),
      ));
    }

    Widget buildNoteInput() {
      return Expanded(
        child: TextField(
          controller: _contentController,
          enabled: widget.isUpdate,
          maxLines: null,
          expands: true,
          style: TextStyle(
            color: const Color.fromARGB(255, 0, 0, 0),
            fontSize: 20,
          ),
          decoration: InputDecoration(
            hintText: 'Type here...',
            hintStyle: TextStyle(
              color: const Color.fromARGB(53, 0, 0, 0),
              fontSize: 20,
            ),
            contentPadding: EdgeInsets.only(top: 10, left: 15),
            border: InputBorder.none,
          ),
        ),
      );
    }

    Future<void> _SaveNote(Notes note) async {
      await _notesBox.put(note.id, note);
    }

    Future<void> _SaveTODOList(Tasks task) async {
      await _tasksBox.put(task.id, task);
    }

    Future<void> _updateNote(Notes note) async {
      _notesBox.delete(note.id);
      await _notesBox.put(note.id, note);
    }

    Future<void> _updateTasks(Tasks task) async {
      _tasksBox.delete(task.id);
      await _tasksBox.put(task.id, task);
    }

    return Scaffold(
      // Changed from MaterialApp to Scaffold
      appBar: AppBar(backgroundColor: const Color.fromARGB(255, 252, 193, 16)),
      body: Column(
        children: [
          TextField(
            controller: _titleController,
            enabled: widget.isUpdate,
            style: TextStyle(
              color: const Color.fromARGB(213, 0, 0, 0),
              fontSize: 25,
              fontWeight: FontWeight.w500,
              fontFamily: "sans-serif",
            ),
            decoration: InputDecoration(
              hintText: "title",
              hintStyle: TextStyle(
                color: const Color.fromARGB(53, 0, 0, 0),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
              contentPadding: EdgeInsets.only(left: 15),
            ),
          ),
          buildTagsInput(),

          // buildNoteInput(),]

          (selectedTag == 'Shopping' || selectedTag == 'Tasks')
              ? buildToDoListInput()
              : buildNoteInput(),

          //-----------------------------------------------------------
          // Single save button with proper validation

          MaterialButton(
            onPressed: () async {
              //---------------------note validation---------------------start

              if ((selectedTag == 'Note' || selectedTag == 'Dairy' || selectedTag=='')) {
                if ((_titleController.text.isEmpty ||
                    _contentController.text.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                setState(() {}); // Show loading state
                if (widget.existingNote != null) {
                  final newNote = Notes(
                    id: widget.existingNote?.id ?? 0,
                    title: _titleController.text,
                    content: _contentController.text,
                    tag: selectedTag,
                  );
                  if (!_notesBox.isOpen) {
                    _notesBox = await Hive.openBox<Notes>('notesBox');
                  }
                  _updateNote(newNote);
                  Navigator.of(context).pop(true);
                } else {
                  final newNote = Notes(
                    id: _notesBox.keys.isEmpty
                        ? 0
                        : (_notesBox.keys.last as int) +
                            1, // Better ID generation
                    title: _titleController.text,
                    content: _contentController.text,
                    tag: selectedTag,
                  );

                  // Safe box access
                  if (!_notesBox.isOpen) {
                    _notesBox = await Hive.openBox<Notes>('notesBox');
                  }

                  _SaveNote(newNote);

                  Navigator.of(context).pop(true);
                }
              }
              //----------------------note validation---------------------end
              //----------------------tasks validation---------------------start
            
              if ((selectedTag == 'Shopping' || selectedTag == 'Tasks')) {
                if ((_titleController.text.isEmpty || tasks.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                setState(() {}); // Show loading state
                if (widget.existingTODOlist != null) {
                  final newTODOlist = Tasks(
                    id: widget.existingTODOlist?.id ?? 0,
                    title: _titleController.text,
                    tasks: tasks,
                    tag: selectedTag,
                  );
                  if (!_tasksBox.isOpen) {
                     _tasksBox = await Hive.openBox<Tasks>('taskBox');
                  }
                  _updateTasks(newTODOlist);
                  Navigator.of(context).pop(true);
                } else {
                  final newTODOlist = Tasks(
                    id: _tasksBox.keys.isEmpty
                        ? 0
                        : (_tasksBox.keys.last as int) +
                            1, // Better ID generation
                    title: _titleController.text,
                    tasks: tasks,
                    tag: selectedTag,
                  );

                  // Safe box access
                  if (!_tasksBox.isOpen) {
                    _tasksBox = await Hive.openBox<Tasks>('taskBox');
                  }

                  _SaveTODOList(newTODOlist);

                  Navigator.of(context).pop(true);
                }
              }
            },
            color: Colors.blue[400],
            minWidth: double.infinity,
            height: 55,
            child: Text(
              widget.isUpdate == true ? "Save" : "Back",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
