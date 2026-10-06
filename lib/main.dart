import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'db/entities/note_database.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final databasesPath = await sqflite.getDatabasesPath();
  final databasePath = p.join(databasesPath, 'notes.db');
  final databaseFile = File(databasePath);
  if (!await databaseFile.exists()) {
    final data = await rootBundle.load('assets/databases/notes.db');
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    await databaseFile.writeAsBytes(bytes, flush: true);
  }
  final database =
  await $FloorNoteDatabase.databaseBuilder('notes.db').build();
  runApp(
    MyApp(database: database),
  );
}
class MyApp extends StatelessWidget {
  final NoteDatabase database;
  const MyApp({
    super.key,
    required this.database,
  });
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes App',
      home: const Scaffold(
        body: Center(
          child: Text('Notes App'),
        ),
      ),
    );
  }
}