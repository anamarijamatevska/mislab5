import 'location.dart';

class Termin {
  final String id;
  final String title;
  final DateTime date;
  final Location location;

  Termin({
    required this.id,
    required this.title,
    required this.date,
    required this.location
  });
}
