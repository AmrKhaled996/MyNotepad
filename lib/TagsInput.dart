import 'package:flutter/material.dart';

class TagsInputField extends StatefulWidget {
  @override
  _TagsInputFieldState createState() => _TagsInputFieldState();
}

class _TagsInputFieldState extends State<TagsInputField> {

   TextEditingController tagsController = TextEditingController();
  final List<String> _availableTags = ['Flutter', 'Dart', 'Firebase', 'UI', 'State Management'];
  bool _showDropdown = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Only TextField with dropdown - no chips displayed
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: tagsController,
                decoration: InputDecoration(
                  hintText: 'Add tags...',
                  border: OutlineInputBorder(),
                  suffixIcon:   IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _showTagOptions(context),
            ),
                ),
                onChanged: (value) {
                  setState(() {
                    _showDropdown = value.isNotEmpty;
                  });
                },
              ),
            ),
          
          ],
        ),
        
        // Dropdown list
        if (_showDropdown && tagsController.text.isNotEmpty)
          Container(
            constraints: BoxConstraints(maxHeight: 200),
            child: ListView(
              shrinkWrap: true,
              children: _availableTags
                  .where((tag) => tag.toLowerCase().contains(tagsController.text.toLowerCase()))
                  .map((tag) => ListTile(
                    title: Text(tag),
                    onTap: () {
                      setState(() {
                        tagsController.text +=" ,$tag"; // Only put value in TextField
                        _showDropdown = false;
                      });
                    },
                  ))
                  .toList(),
            ),
          ),
      ],
    );
  }

  void _showTagOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Available Tags', style: TextStyle(fontSize: 18)),
              ),
              Expanded(
                child: ListView(
                  children: _availableTags
                      .map((tag) => ListTile(
                            title: Text(tag),
                            onTap: () {
                              setState(() {
                                tagsController.text = tag; // Only put value in TextField
                                Navigator.pop(context);
                              });
                            },
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}