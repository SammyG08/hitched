import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Guests extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  TextColumn get rsvpStatus => text().withDefault(
    const Constant('pending'),
  )(); // pending, attending, declined
  TextColumn get dietaryNotes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Settings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get weddingDate => text()();
  TextColumn get partnerAName => text()();
  TextColumn get partnerBName => text()();
}

@DriftDatabase(tables: [Guests, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = File(p.join(Directory.current.path, 'wedding.db'));
    return NativeDatabase(file);
  });
}
