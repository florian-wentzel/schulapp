import 'package:flutter/material.dart';
import 'package:schulapp/app.dart';
import 'package:schulapp/code_behind/save_manager.dart';

void main() async {
  //sichergehen dass alle plugins initialisiert wurden
  WidgetsFlutterBinding.ensureInitialized();
  await SaveManager().loadApplicationDocumentsDirectory();
  runApp(const MainApp());
}

//file_picker setup: (already working for: windows)
//https://github.com/miguelpruivo/flutter_file_picker/wiki/Setup

//Save data online
//https://stackoverflow.com/questions/68955545/flutter-how-to-backup-user-data-on-google-drive-like-whatsapp-does