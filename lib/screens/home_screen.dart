import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/task.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _taskController = TextEditingController();
  List<Task> _tasks = [];
  List<bool> _tasksDone = [];

  // Save the task to SharedPreferences
  void saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Task t = Task.fromString(_taskController.text);
    String tasks = prefs.getString('task') ?? '[]';
    List list = (tasks == null)?[] : json.decode(tasks);
    print(list);
    list.add(json.encode(t.getMap()));
    print(list);
    prefs.setString('task', json.encode(list));
    _taskController.text = ''; // Clear the input field
    Navigator.of(context).pop(); // Close the modal
    _getTasks();
  }

  // Fetch tasks from SharedPreferences
  void _getTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tasks = prefs.getString('task') ?? '[]';
    List list = json.decode(tasks);

    // Convert each task from map to Task object
    _tasks = list.map((e) => Task.fromMap(json.decode(e))).toList();
    _tasksDone = List.generate(_tasks.length, (index) => false);

    setState(() {}); // Update UI after fetching tasks
  }

  // Update the list of tasks that are not done
  void updatePendingTasksList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Task> pendingList = [];
    for (var i = 0; i < _tasks.length; i++)
      if (!_tasksDone[i]) pendingList.add(_tasks[i]);

    var pendingListEncoded = List.generate(
        pendingList.length, (i) => json.encode(pendingList[i].getMap()));

    prefs.setString('task', json.encode(pendingListEncoded));
    _getTasks();
  }

  @override
  void initState() {
    super.initState();
    _getTasks(); // Load tasks when the screen initializes
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.black,
        title: Text(
          'Task Manager',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: updatePendingTasksList,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('task', json.encode([])); // Clear all tasks
              _getTasks(); // Refresh task list
            },
          ),
        ],
      ),
      body: (_tasks.isEmpty)
          ? Center(child: Text('No Tasks added yet!'),)
          : Column(
        children: _tasks
            .map(
              (e) => Container(
            height: 70.0,
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 5.0,
            ),
            padding: const EdgeInsets.only(left: 10.0),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                color: Colors.black,
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  e.task,
                ),
                Checkbox(
                  value: _tasksDone[_tasks.indexOf(e)],
                  onChanged: (val) {
                    setState(() {
                      _tasksDone[_tasks.indexOf(e)] = val ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
        )
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (BuildContext context) => Container(
            padding: const EdgeInsets.all(10.0),
            height: 250,
            color: Colors.blue[200],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add task',
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                Divider(thickness: 1.2),
                SizedBox(height: 20.0),
                TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Enter task',
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Container(
                        width: (MediaQuery.of(context).size.width / 2) - 20,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                          child: Text(
                            'RESET',
                          ),
                          onPressed: () => _taskController.text = '',
                        ),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width / 2) - 20,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          child: Text(
                            'ADD',
                          ),
                          onPressed: () => saveData(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
