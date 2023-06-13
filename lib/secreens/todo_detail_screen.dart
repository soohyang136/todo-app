import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TodoDetailScreen extends StatefulWidget {
  final int id;

  TodoDetailScreen({required this.id});

  @override
  State<TodoDetailScreen> createState() => _StateTodoDetailScreen();
}

class Todo {
  final String title;
  final String content;

  Todo({required this.title, required this.content});
}

class _StateTodoDetailScreen extends State<TodoDetailScreen> {
  late Todo todo = Todo(title: "", content: "");
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    getTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFFFEE1E8),
        title: Text('Todo Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Text(
              todo.title,
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
              ),
            )),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Text(
                '상세 설명',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              todo.content,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(380, 48),
                      backgroundColor: Color(0xFFFEE1E8)),
                  onPressed: () => {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                  title: Text('TODO 수정'),
                                  content: Column(
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
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          updateTodo();
                                        },
                                        child: Text('수정'))
                                  ],
                                ))
                      },
                  child: Text(
                    "수정",
                    style: TextStyle(color: Colors.black),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(380, 48),
                    backgroundColor: Color(0xFFFEE1E8)),
                onPressed: deleteTodo,
                child: Text("삭제", style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getTodo() async {
    final url =
        Uri.parse('http://10.0.2.2:8000/api/todo/' + widget.id.toString());
    final response = await http.get(url);
    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
    setState(() {
      todo =
          Todo(title: responseBody["title"], content: responseBody["content"]);
    });
    print(response.statusCode);
  }

  void deleteTodo() async {
    final url =
        Uri.parse('http://10.0.2.2:8000/api/todo/' + widget.id.toString());
    final response = await http.delete(url);
    Navigator.pop(context);
    print(response.statusCode);
  }

  void updateTodo() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/todo/' + widget.id.toString());
    final response = await http.put(url, body: {"title": _titleController.text, "content": _contentController.text});
    getTodo();
    Navigator.of(context).pop();
  }
}
