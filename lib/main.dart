import 'package:flutter/material.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyNavigationPage(),
    );
  }
}

class MyNavigationPage extends StatefulWidget {
  const MyNavigationPage({super.key});

  @override
  State<MyNavigationPage> createState() => _MyNavigationPageState();
}

class _MyNavigationPageState extends State<MyNavigationPage> {
  int currentPageIndex = 0;

  Widget PageState() {
    switch (currentPageIndex) {
      case 0:
        return MyHomePage();
      case 1:
        return MyCalendarPage();
      case 2:
        return MyHomeworkPage();
      default:
        return MyHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_work),
            label: 'Homework',
          ),
        ],
      ),
      body: PageState(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Home'),
      ),
    );
  }
}

class MyCalendarPage extends StatelessWidget {
  const MyCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Calendar'),
      ),
    );
  }
}

class MyHomeworkPage extends StatelessWidget {
  const MyHomeworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Homework'),
      ),
    );
  }
}
