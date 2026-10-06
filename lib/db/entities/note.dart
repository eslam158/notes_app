import 'package:floor/floor.dart';
@Entity(tableName:'notes')
 class Note {
  @PrimaryKey(autoGenerate: true)
  final int ? id;
  final String title, text;
  final String? location;

  Note(
      { this.id, required this.title, required this.text,  this.location});
}
