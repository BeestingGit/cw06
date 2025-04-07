import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addTask() {
    final taskName = _taskController.text.trim();
    if (taskName.isNotEmpty) {
      _firestore.collection('tasks').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'name': taskName,
        'completed': false,
        'nestedTasks': [],
      });
      _taskController.clear();
    }
  }

  void _toggleTaskCompletion(String taskId, bool currentStatus) {
    _firestore.collection('tasks').doc(taskId).update({
      'completed': !currentStatus,
    });
  }

  void _deleteTask(String taskId) {
    _firestore.collection('tasks').doc(taskId).delete();
  }

  void _addSubTask(String taskId, String subTaskName) {
    _firestore.collection('tasks').doc(taskId).update({
      'nestedTasks': FieldValue.arrayUnion([subTaskName]),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(labelText: 'Enter Task'),
                  ),
                ),
                IconButton(icon: Icon(Icons.add), onPressed: _addTask),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream:
                  _firestore
                      .collection('tasks')
                      .where(
                        'userId',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                      )
                      .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final tasks = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ExpansionTile(
                      leading: Checkbox(
                        value: task['completed'],
                        onChanged: (newValue) {
                          _toggleTaskCompletion(task.id, task['completed']);
                        },
                      ),
                      title: Text(task['name']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteTask(task.id),
                      ),
                      children: [
                        ...task['nestedTasks'].map<Widget>((subTask) {
                          return ListTile(title: Text(subTask));
                        }).toList(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Add Subtask',
                                  ),
                                  onSubmitted:
                                      (subTaskName) =>
                                          _addSubTask(task.id, subTaskName),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
