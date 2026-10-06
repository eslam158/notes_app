import 'package:floor/floor.dart';
import '../entities/note.dart';

@dao
abstract class NoteDao {
  @Query('SELECT * FROM notes')
  Future<List<Note>> selectNotes();

  @insert
  Future<int> insertNote(Note insertNote);

  @update
  Future<int> updateNote(Note updateNote);

  @delete
  Future<int> deleteNote(Note deleteNote);

  @Query('DELETE FROM notes')
  Future<void> deleteAll();
}