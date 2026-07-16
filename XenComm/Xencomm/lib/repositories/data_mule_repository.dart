import '../models/data_mule_model.dart';

abstract class DataMuleRepository {
  Future<DataMule> createDataMule(DataMule mule);
  Future<DataMule?> getDataMuleByID(String vehicleID);
  Future<List<DataMule>> getAllDataMules();
  Future<List<DataMule>> getDataMulesByStatus(String status);
  Future<void> updateDataMule(DataMule mule);
  Future<void> deleteDataMule(String vehicleID);
  Future<void> addBundleToMule(String vehicleID, String bundleID);
  Future<void> removeBundleFromMule(String vehicleID, String bundleID);
}
