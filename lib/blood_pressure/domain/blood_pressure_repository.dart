import 'package:tonometr/database/db.dart';

abstract class BloodPressureRepository {
  Future<List<Measurement>> getAllMeasurements();
  Future<void> addMeasurement(Measurement measurement);
  Future<void> deleteMeasurement(Measurement measurement);
}
