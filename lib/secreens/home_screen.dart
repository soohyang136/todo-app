import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:todo/secreens/todo_detail_screen.dart';

import 'add_todo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late TextEditingController _todoController;

  List<dynamic> todoList = [];

  @override
  void initState() {
    super.initState();
    _todoController = TextEditingController();
    searchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Center(child: Text('나만의 TODO', style: TextStyle(color: Color(0xFFF3B0C3)),),),
          backgroundColor: Color(0xFFFEE1E8),
        ),
        body: Column(
          children: [
            buildTableCalendar(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    _selectedDay.month.toString() +
                        "월" +
                        _selectedDay.day.toString() +
                        "일" +
                        " TODO",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: TextButton(
                      onPressed: navigateToAddScreen,
                      child: Text(
                        "추가",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      )),
                ),
              ],
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: buildListView(),
            )),
          ],
        ));
  }

  ListView buildListView() {
    return ListView.separated(
      separatorBuilder: (context, index) => SizedBox(height: 10),
      itemCount: todoList.length,
      itemBuilder: (context, index) {
        final todo = todoList[index];
        return ElevatedButton(
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color(0xFFFEE1E8))),
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TodoDetailScreen(
                        id: todo["id"],
                      )),
            ).then((value) => {searchTodo()});
          },
          child: SizedBox(
            height: 60, // 원하는 높이로 조정
            child: ListTile(
              title: Text(
                todo["title"],
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: Checkbox(
                fillColor: MaterialStateProperty.all(Colors.black),
                value: todo["completed"],
                onChanged: (value) {
                  if (value == true) {
                    makeCompleted(todo["id"]);
                  } else {
                    makeUncompleted(todo["id"]);
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Padding buildTableCalendar() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: TableCalendar(
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFEE1E8)
          )
        ),
        firstDay: DateTime.utc(2021, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            searchTodo();
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  void searchTodo() async {
    var requestDate = getYearMonthDay();
    print(requestDate);
    final url = Uri.parse('http://10.0.2.2:8000/api/todo?date=' + requestDate);
    final response = await http.get(url);
    print(response.statusCode);
    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
    setState(() {
      todoList = responseBody;
    });
    print(responseBody);
  }

  String getYearMonthDay() {
    return _selectedDay.year.toString() +
        "-" +
        _selectedDay.month.toString() +
        "-" +
        _selectedDay.day.toString();
  }

  void makeUncompleted(int? id) async {
    final url =
        Uri.parse('http://10.0.2.2:8000/api/todo/uncomplete/' + id.toString());
    final response = await http.put(url);
    print(response.statusCode);
    searchTodo();
  }

  void makeCompleted(int? id) async {
    final url =
        Uri.parse('http://10.0.2.2:8000/api/todo/complete/' + id.toString());
    final response = await http.put(url);
    print(response.statusCode);
    searchTodo();
  }

  void navigateToAddScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddTodoScreen(
                date: getYearMonthDay(),
              )),
    ).then((value) => {searchTodo()});
  }
}
