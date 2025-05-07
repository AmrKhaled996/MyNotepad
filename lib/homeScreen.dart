import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:share_plus/share_plus.dart';
import 'package:test_work_sapce/hiveDatabase.dart';

import 'package:test_work_sapce/noteField.dart';
import 'package:test_work_sapce/notes.dart';
import 'package:test_work_sapce/tasks.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => homeScreenState();
}

class homeScreenState extends State<HomeScreen> {
  // Get fresh notes from Hive every time
  HiveService hiveService = HiveService();
  List<Notes> notes = [];
  List<Tasks> TODOLists = [];
  Box<Notes> _notesBox = Hive.box('noteBox');
  Box<Tasks> _tasksBox = Hive.box('taskBox');

  int? segmentbarIndex = 0;

  //by deepseek : formated tasks to string to share it


  String _formatTaskListForSharing(Tasks taskList) {
    final buffer = StringBuffer();
    buffer.writeln('${taskList.title}\n');

    for (final task in taskList.tasks) {
      buffer.writeln('${task.completed ? '[✓]' : '[ ]'} ${task.content}');
    }

    return buffer.toString();
    
  }



  void initState() {
    super.initState();
    notes = hiveService.getNotes();
    TODOLists = hiveService.getTasks();
  }

  @override
  Widget build(BuildContext context) {
    void ReloadNotes() {
      setState(() {
        notes = hiveService.getNotes();
      });
    }

    void ReloadTasks() {
      setState(() {
        TODOLists = hiveService.getTasks();
      });
    }

    Widget buildTaskList() {
      return ListView.builder(
        itemCount: TODOLists.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromARGB(133, 218, 215, 215),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: MaterialButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 30,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    hoverColor: Colors.transparent,
                    onPressed: () async {
                      final shouldRefresh = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Notefield(
                            existingTODOlist: TODOLists[index],
                            isUpdate: false,
                            // existingNote: note,
                          ),
                        ),
                      );
                      if (shouldRefresh == true) ReloadTasks();
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TODOLists[index].title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            TODOLists[index].tag,
                            style: const TextStyle(fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            //--------------------container contains the tasks---------------
                            constraints: BoxConstraints(
                              maxHeight: 400,
                              minHeight: 40,
                            ),

                            // child: Expanded(
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: TODOLists[index].tasks.length,
                                itemBuilder: (context, i) {
                                  return Row(children: [
                                    Checkbox(
                                      value:
                                          TODOLists[index].tasks[i].completed,
                                      activeColor: Colors.blue[400],
                                      onChanged: (bool? value) {
                                        setState(() {
                                          TODOLists[index].tasks[i].completed =
                                              value!;

                                          //deepseek : update the task in the hive
                                          _tasksBox.put(TODOLists[index].id,
                                              TODOLists[index]);

                                          ReloadTasks();
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child:
                                    Container(
                                      constraints: BoxConstraints(
                                        maxHeight: 50,
                                        minHeight: 40,
                                        // maxWidth: 100,
                                      ),
                                      alignment: Alignment(-1, 0),
                                      child: Text(
                                          TODOLists[index].tasks[i].content,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 0, 0, 0),
                                            fontSize: 20,
                                          )),
                                    ),
                                  )
                                  ]);
                                }),
                            // )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //edit data from hive and reload the notes
                      IconButton(
                        icon: const Icon(Icons.edit, size: 35),
                        padding: const EdgeInsets.all(10),
                        onPressed: () async {
                          final shouldRefresh = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Notefield(
                                existingTODOlist: TODOLists[index],
                                isUpdate: true,
                              ),
                            ),
                          );
                          if (shouldRefresh == true) ReloadNotes();
                        },
                      ),

                      //delete data from hive and reload the notes

                      IconButton(
                        icon: const Icon(Icons.delete, size: 35),
                        padding: const EdgeInsets.all(10),
                        onPressed: () {
                          setState(() async {
                            await _tasksBox.delete(
                              TODOLists[index].id,
                            );
                            ReloadTasks();
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, size: 35),
                        padding: const EdgeInsets.all(10),
                        onPressed: () {
                          // ignore: deprecated_member_use
                          Share.share(
                              _formatTaskListForSharing(TODOLists[index]),
                              subject: TODOLists[index].title);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    Widget buildNoteList() {
      return ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return Container(
            
            margin: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            width: double.infinity,
            // height: 150,
            decoration: BoxDecoration(
              color: const Color.fromARGB(133, 218, 215, 215),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: MaterialButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 30,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    hoverColor: Colors.transparent,
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Notefield(
                            existingNote: notes[index],
                            isUpdate: false,
                            // existingNote: note,
                          ),
                        ),
                      );
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notes[index].title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            notes[index].tag,
                            style: const TextStyle(fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            notes[index].content,
                            style: const TextStyle(fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //edit data from hive and reload the notes
                      IconButton(
                        icon: const Icon(Icons.edit, size: 35),
                        padding: const EdgeInsets.all(10),
                        onPressed: () async {
                          final shouldRefresh = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Notefield(
                                existingNote: notes[index],
                                isUpdate: true,
                              ),
                            ),
                          );
                          if (shouldRefresh == true) ReloadNotes();
                        },
                      ),

                      //delete data from hive and reload the notes

                      IconButton(
                        icon: const Icon(Icons.delete, size: 35),
                        padding: const EdgeInsets.all(10),
                        onPressed: () {
                          setState(() async {
                            await _notesBox.delete(
                              notes[index].id,
                            );
                            ReloadNotes();
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, size: 35),
                        padding: const EdgeInsets.all(10),
                        onPressed: () {
                          // ignore: deprecated_member_use
                          Share.share(notes[index].content,
                              subject: notes[index].title);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      // Changed from MaterialApp to Scaffold
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 252, 193, 16),
          title: TextField(
            onChanged: (value) {
              setState(() {
                notes = hiveService.searchNotes(value);
                TODOLists = hiveService.searchTasks(value);
              });
            },
            decoration: const InputDecoration(
              hintText: "Search",
              hintStyle: TextStyle(color: Colors.black),
              contentPadding: EdgeInsets.only(left: 20),
            ),
          )),
      floatingActionButton: FloatingActionButton(
        hoverColor: Colors.transparent,
        onPressed: () async {
          final shouldRefresh = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Notefield(
                      isUpdate: true,
                    )),
          );
          if (shouldRefresh == true) ReloadNotes();
          if (shouldRefresh == true) ReloadTasks();
        },
        child: Icon(
          Icons.add,
          semanticLabel: "Add Note",
          size: 30,
          color: const Color.fromARGB(183, 0, 0, 0),
        ),
        backgroundColor: Colors.amber[400],
        shape: CircleBorder(
          side: BorderSide(color: Colors.amber[400]!, width: 2),
        ),
      ),






      //list of notes or list of tasks
      body:
      Column(children: [
        Container(
          width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20),
        child: CupertinoSegmentedControl<int>(
          onValueChanged: (int value) {
            setState(() {
              segmentbarIndex = value;
            });
          },
          selectedColor: Colors.blue[400],
          borderColor:Colors.blue[400] ,
          pressedColor:const Color.fromARGB(15, 66, 164, 245) ,
          children: const {
            0: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Notes'),
            ),
            1: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Tasks'),
            ),
          },
          groupValue: segmentbarIndex,
        ),
      ),
      Container(
        constraints: BoxConstraints(
          maxHeight: 580,
          minHeight: 100,
        ),
        child: 
        segmentbarIndex == 0 ? buildNoteList() : buildTaskList()
        
        ,
      )
      ],)



    );
  }
}
