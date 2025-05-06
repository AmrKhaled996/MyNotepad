import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:share_plus/share_plus.dart';
import 'package:test_work_sapce/hiveDatabase.dart';

import 'package:test_work_sapce/noteField.dart';
import 'package:test_work_sapce/notes.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => homeScreenState();
}

class homeScreenState extends State<HomeScreen> {
  // Get fresh notes from Hive every time
  HiveService hiveService = HiveService();
  List<Notes> notes = [];
  Box<Notes> _notesBox = Hive.box('noteBox');

  void initState() {
    super.initState();
    notes = hiveService.getNotes();
  }

  @override
  Widget build(BuildContext context) {
    void ReloadNotes() {
      setState(() {
        notes = hiveService.getNotes();
      });
    }
  
    return Scaffold(
      // Changed from MaterialApp to Scaffold
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 252, 193, 16),
          title: TextField(

            onChanged: (value) {
              setState(() {
                notes = hiveService.searchNotes(value);
              });
            },
            decoration: const InputDecoration(
              hintText: "Search",
              hintStyle: TextStyle(color: Colors.black),
              
              contentPadding: EdgeInsets.only(left: 20),
            ),
          )),
      // floatingActionButton: Container(
        
      //   margin: const EdgeInsets.only(bottom:20, right: 0),
      //   width:140,
      //   padding: const EdgeInsets.only(left: 0,right: 10),
      floatingActionButton: FloatingActionButton(
        
          hoverColor: Colors.transparent,
          onPressed: ()async {
          final shouldRefresh =  await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Notefield(isUpdate: true,)),
                      );
                      if (shouldRefresh == true) ReloadNotes();
          }, 
          child: Icon(Icons.add ,semanticLabel: "Add Note", size: 30, color: const Color.fromARGB(183, 0, 0, 0),),
          backgroundColor: Colors.amber[400],
          shape: CircleBorder( 
            side: BorderSide(color: Colors.amber[400]!, width: 2), 
          ),
  
  
  //   child: Container(
  //     height: 70,
  //     width: 150, 
  //     child: DropdownButton<String>(
  //       focusColor: Colors.transparent,
        
  //       menuWidth: 120,
  //       menuMaxHeight: 200,

        
  //       underline: const SizedBox(), // Remove default underline
  //       dropdownColor: Colors.white, // Match dropdown background
  //       elevation: 4, // Add shadow
  //       isDense: true, // Reduce padding
  //       icon: const Icon(Icons.add, size: 30 ,), // Centered icon
        
  //       style: TextStyle(color: Colors.black), // Text color
  //       alignment: Alignment.centerLeft,
  //       onChanged: (val) async {

  //         if (val == "Add Note") {
  //           await Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => Notefield(isUpdate: true,)),
  //           );
  //         } else if (val == "Add ToDo list") {
  //           // Handle ToDo list navigation
  //         }
  //       },
  //       items: const [
  //         DropdownMenuItem(
            
  //           alignment: Alignment.center,
  //           value: "Add Note",
  //             child:SizedBox(
  //               width: 50,
  //               child:
  //             Text("Add Note",  style: TextStyle(color: Colors.black ,fontSize: 12, fontWeight: FontWeight.bold), )),
               
            
  //           ),
  //         DropdownMenuItem(
  //           alignment: Alignment.center,
  //             value: "Add ToDo list",
  //             child:SizedBox(
  //               width:50,
  //               child:
  //             Text("Add ToDo list", style: TextStyle(color: Colors.black ,fontSize: 12 ,fontWeight: FontWeight.bold), )),
  //             ) 
  //       ],
  //     ),
    
  // ),      ),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          // print(
          //   "${note.id}  ${note.title}   ${note.content}   ${note.tags}",
          // );
          // final tagsInLine = _notes[index].tags.join(" ");
          
          return Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            width: double.infinity,
            height: 150,
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
                        icon: const Icon(Icons.share , size: 35),
                        padding: const EdgeInsets.all(10),
                        onPressed: () {
                             // ignore: deprecated_member_use
                             Share.share(notes[index].content, subject: notes[index].title);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
