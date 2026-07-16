import 'dart:convert';

import '../../models/data_mule_model.dart';
import '../../services/database/database_service.dart';
import '../data_mule_repository.dart';

class DataMuleRepositoryImpl implements DataMuleRepository {
  final DatabaseService _dbService = DatabaseService();

  @override
  Future<DataMule> createDataMule(DataMule mule) async {
    await _dbService.insert('datamules', {
      'vehicleID': mule.vehicleID,
      'type': mule.type,
      'capacity': mule.capacity,
      'currentHub': mule.currentHub,
      'nextHub': mule.nextHub,
      'speed': mule.speed,
      'status': mule.status,
      'bundlesCarrying': jsonEncode(mule.bundlesCarrying),
      'createdAt': mule.createdAt.toIso8601String(),
    });
    return mule;
  }

  @override
  Future<DataMule?> getDataMuleByID(String vehicleID) async {
    final result = await _dbService.query('datamules', where: 'vehicleID = ?', whereArgs: [vehicleID]);
    if (result.isEmpty) return null;
    final data = Map<String, dynamic>.from(result.first);
    data['bundlesCarrying'] = List<String>.from(jsonDecode(data['bundlesCarrying'] as String));
    data['createdAt'] = DateTime.parse(data['createdAt'] as String);
    return DataMule.fromJson(data);
  }

  @override
  Future<List<DataMule>> getAllDataMules() async {
    final result = await _dbService.query('datamules');
    return result.map((json) {
      final data = Map<String, dynamic>.from(json);
      data['bundlesCarrying'] = List<String>.from(jsonDecode(data['bundlesCarrying'] as String));
      data['createdAt'] = DateTime.parse(data['createdAt'] as String);
      return DataMule.fromJson(data);
    }).toList();
  }

  @override
  Future<List<DataMule>> getDataMulesByStatus(String status) async {
    final result = await _dbService.query('datamules', where: 'status = ?', whereArgs: [status]);
    return result.map((json) {
      final data = Map<String, dynamic>.from(json);
      data['bundlesCarrying'] = List<String>.from(jsonDecode(data['bundlesCarrying'] as String));
      data['createdAt'] = DateTime.parse(data['createdAt'] as String);
      return DataMule.fromJson(data);
    }).toList();
  }

  @override
  Future<void> updateDataMule(DataMule mule) async {
    await _dbService.update(
      'datamules',
      {
        'vehicleID': mule.vehicleID,
        'type': mule.type,
        'capacity': mule.capacity,
        'currentHub': mule.currentHub,
        'nextHub': mule.nextHub,
        'speed': mule.speed,
        'status': mule.status,
        'bundlesCarrying': jsonEncode(mule.bundlesCarrying),
        'createdAt': mule.createdAt.toIso8601String(),
      },
      where: 'vehicleID = ?',
      whereArgs: [mule.vehicleID],
    );
  }

  @override
  Future<void> deleteDataMule(String vehicleID) async {
    await _dbService.delete('datamules', where: 'vehicleID = ?', whereArgs: [vehicleID]);
  }

  @override
  Future<void> addBundleToMule(String vehicleID, String bundleID) async {
    final mule = await getDataMuleByID(vehicleID);
    if (mule == null) throw Exception('Data mule not found');
    final bundles = List<String>.from(mule.bundlesCarrying);
    if (!bundles.contains(bundleID)) {
      bundles.add(bundleID);
      await updateDataMule(mule.copyWith(bundlesCarrying: bundles));
    }
  }

  @override
  Future<void> removeBundleFromMule(String vehicleID, String bundleID) async {
    final mule = await getDataMuleByID(vehicleID);
    if (mule == null) throw Exception('Data mule not found');
    final bundles = List<String>.from(mule.bundlesCarrying)..remove(bundleID);
    await updateDataMule(mule.copyWith(bundlesCarrying: bundles));
  }
}
