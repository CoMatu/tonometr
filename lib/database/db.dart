import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

part 'db.g.dart';

class Measurements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get systolic => integer()();
  IntColumn get diastolic => integer()();
  IntColumn get pulse => integer()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Measurements])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<int> addMeasurement(MeasurementsCompanion entry) =>
      into(measurements).insert(entry);
  Future<List<Measurement>> getAllMeasurements() => select(measurements).get();
  Future<int> deleteMeasurement(Measurement measurement) =>
      (delete(measurements)
        ..where((tbl) => tbl.id.equals(measurement.id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
