import 'package:notesapp/db/daos/note_dao.dart';
import 'package:notesapp/db/entities/note.dart';

class NoteService {
  final NoteDao noteDao;

  NoteService(this.noteDao);

  Future<List<Note>> getNotes() {
    return noteDao.selectNotes();
  }

  Future<int> addNote(Note note) {
    return noteDao.insertNote(note);
  }

  Future<int> updateNote(Note note) {
    return noteDao.updateNote(note);
  }

  Future<int> deleteNote(Note note) {
    return noteDao.deleteNote(note);
  }

  Future<void> deleteAllNotes() {
    return noteDao.deleteAll();
  }
}