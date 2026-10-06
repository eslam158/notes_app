import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../db/entities/note.dart';
import '../db/entities/note_database.dart';
import '../services/note_service.dart';

class AddNoteScreen extends StatefulWidget {
  final NoteDatabase database;

  const AddNoteScreen({
    super.key,
    required this.database,
  });

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final titleController = TextEditingController();
  final textController = TextEditingController();
  final locationController = TextEditingController();

  late final NoteService noteService;

  bool isSaving = false;
  bool isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    noteService = NoteService(widget.database.noteDao);
  }

  @override
  void dispose() {
    titleController.dispose();
    textController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> getCurrentLocation() async {
    setState(() {
      isGettingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please turn on location services'),
          ),
        );

        setState(() {
          isGettingLocation = false;
        });

        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied'),
            ),
          );

          setState(() {
            isGettingLocation = false;
          });

          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission is permanently denied. '
                  'Please enable it from settings.',
            ),
          ),
        );

        setState(() {
          isGettingLocation = false;
        });

        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      locationController.text =
      '${position.latitude}, ${position.longitude}';

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Current location added'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to get current location'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isGettingLocation = false;
        });
      }
    }
  }

  Future<void> saveNote() async {
    final title = titleController.text.trim();
    final text = textController.text.trim();
    final location = locationController.text.trim();

    if (title.isEmpty || text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title and note text are required'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final note = Note(
        title: title,
        text: text,
        location: location.isEmpty ? null : location,
      );

      await noteService.addNote(note);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save note'),
        ),
      );

      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF171717),
          ),
        ),
        title: const Text(
          'New Note',
          style: TextStyle(
            color: Color(0xFF171717),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Title',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            _InputField(
              controller: titleController,
              hint: 'Enter note title',
              icon: Icons.title_rounded,
            ),
            const SizedBox(height: 22),
            const Text(
              'Note',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            _InputField(
              controller: textController,
              hint: 'Write your note...',
              icon: Icons.edit_note_rounded,
              maxLines: 7,
            ),
            const SizedBox(height: 22),
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            _InputField(
              controller: locationController,
              hint: 'Optional location',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: isGettingLocation ? null : getCurrentLocation,
                icon: isGettingLocation
                    ? const SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  Icons.my_location_rounded,
                ),
                label: Text(
                  isGettingLocation
                      ? 'Getting Location...'
                      : 'Use Current Location',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF171717),
                  side: const BorderSide(
                    color: Color(0xFFD9D9DF),
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF171717),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade400,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Save Note',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textInputAction:
      maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(
            left: 14,
            right: 10,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF777777),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 50,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFF171717),
            width: 1.2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
      ),
    );
  }
}