import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'task_screen.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/login' : '/tasks',
      routes: {
        '/login': (context) => LoginScreen(),
        '/tasks': (context) => TaskListScreen(),
      },
    );
  }
}
