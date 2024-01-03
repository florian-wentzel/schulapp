import 'package:flutter/material.dart';
import 'package:schulapp/app.dart';
import 'package:schulapp/code_behind/save_manager.dart';

void main() async {
  //sichergehen dass alle plugins initialisiert wurden
  WidgetsFlutterBinding.ensureInitialized();
  await SaveManager().loadApplicationDocumentsDirectory();
  runApp(const MainApp());
}

//Save data online
//https://stackoverflow.com/questions/68955545/flutter-how-to-backup-user-data-on-google-drive-like-whatsapp-does
