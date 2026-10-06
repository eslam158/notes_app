import 'package:flutter/material.dart';
import 'package:shake/shake.dart';

import '../db/entities/note.dart';
import '../db/entities/note_database.dart';
import '../services/note_service.dart';
import 'add_note_screen.dart';
import 'edit_note_screen.dart';

class NotesScreen extends StatefulWidget {
  final NoteDatabase database;

  const NotesScreen({
    super.key,
    required this.database,
  });

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late final NoteService noteService;
  ShakeDetector? shakeDetector;

  @override
  void initState() {
    super.initState();

    noteService = NoteService(widget.database.noteDao);

    shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (ShakeEvent event) {
        deleteAllNotes();
      },
      minimumShakeCount: 2,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
      shakeThresholdGravity: 2.7,
      useFilter: true,
    );
  }

  @override
  void dispose() {
    shakeDetector?.stopListening();
    super.dispose();
  }

  Future<void> openAddNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNoteScreen(
          database: widget.database,
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<void> openEditNote(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(
          database: widget.database,
          note: note,
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<void> deleteAllNotes() async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete All Notes?'),
          content: const Text(
            'All notes will be permanently deleted. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Delete All',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await noteService.deleteAllNotes();

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notes deleted'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete all notes'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F7FB),
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'My Notes',
          style: TextStyle(
            color: Color(0xFF171717),
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: FutureBuilder<List<Note>>(
        future: noteService.getNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontSize: 16,
                ),
              ),
            );
          }

          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return const _EmptyNotes();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => openEditNote(notes[index]),
                child: _NoteCard(
                  note: notes[index],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddNote,
        elevation: 4,
        backgroundColor: const Color(0xFF171717),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Note',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;

  const _NoteCard({
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  note.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF171717),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F2F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.more_horiz_rounded,
                  size: 20,
                  color: Color(0xFF555555),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            note.text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF6B6B6B),
            ),
          ),
          if (note.location != null &&
              note.location!.trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F2F6),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 17,
                    color: Color(0xFF555555),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    note.location!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF777777),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.note_alt_outlined,
                size: 42,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No notes yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF171717),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first note and keep\nyour ideas organized.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF777777),
              ),
            ),
          ],
        ),
      ),
    );
  }
}