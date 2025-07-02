import 'package:drift/drift.dart';
import 'package:tonometr/database/db.dart';
import '../domain/blood_pressure_repository.dart';

class BloodPressureRepositoryImpl implements BloodPressureRepository {
  final AppDatabase database;

  BloodPressureRepositoryImpl(this.database);

  @override
  Future<List<Measurement>> getAllMeasurements() {
    return database.getAllMeasurements();
  }

  @override
  Future<void> addMeasurement(Measurement measurement) async {
    final companion = MeasurementsCompanion.insert(
      systolic: measurement.systolic,
      diastolic: measurement.diastolic,
      pulse: measurement.pulse,
      note:
          measurement.note != null
              ? Value(measurement.note!)
              : const Value.absent(),
      createdAt: Value(measurement.createdAt),
    );
    await database.addMeasurement(companion);
  }

  @override
  Future<void> deleteMeasurement(Measurement measurement) async {
    await database.deleteMeasurement(measurement);
  }
}
