import 'package:floor/floor.dart';
// required package imports
import 'dart:async';
import 'package:notesapp/db/daos/note_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:notesapp/db/entities/note.dart';
part 'note_database.g.dart';
@Database(version:1,entities:[Note])
abstract class NoteDatabase extends FloorDatabase{
  NoteDao get noteDao;
}