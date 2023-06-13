import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoScreen extends StatefulWidget {
  final String date;

  AddTodoScreen({required this.date});

  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _addTodo() async {
    if(_titleController.text.isEmpty || _contentController.text.isEmpty) return;
    String title = _titleController.text;
    String content = _contentController.text;

    final url = Uri.parse('http://10.0.2.2:8000/api/todo/create');
    final response = await http.post(
        url, body: {"title": title, "content": content, "date": widget.date});
    print(response.statusCode);

    // Clear the text fields after adding the todo
    _titleController.clear();
    _contentController.clear();

    // Go back to the previous screen (HomeScreen)
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Center(child: Text('나만의 TODO', style: TextStyle(color: Color(0xFFF3B0C3)),),),
        backgroundColor: Color(0xFFFEE1E8),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Content',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addTodo,
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
