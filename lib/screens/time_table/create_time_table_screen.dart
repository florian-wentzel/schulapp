import 'package:flutter/material.dart';

class CreateTimeTableScreen extends StatefulWidget {
  static const String route = "/createTimeTable";
  const CreateTimeTableScreen({super.key});

  @override
  State<CreateTimeTableScreen> createState() => _CreateTimeTableScreenState();
}

class _CreateTimeTableScreenState extends State<CreateTimeTableScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a Time Table"),
      ),
      body: const Center(
        child: Text("TODO :)"),
      ),
    );
  }
}
