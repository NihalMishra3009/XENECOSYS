import 'dart:convert';

import '../../models/bundle_model.dart';
import '../../services/database/database_service.dart';
import '../bundle_repository.dart';

class BundleRepositoryImpl implements BundleRepository {
  final DatabaseService _dbService = DatabaseService();

  @override
  Future<Bundle> createBundle(Bundle bundle) async {
    await _dbService.insert('bundles', {
      'bundleID': bundle.bundleID,
      'sourceHub': bundle.sourceHub,
      'destinationHub': bundle.destinationHub,
      'messageIDs': jsonEncode(bundle.messageIDs),
      'createdAt': bundle.createdAt.toIso8601String(),
      'checksum': bundle.checksum,
      'status': bundle.status,
      'sizeBytes': bundle.sizeBytes,
    });
    return bundle;
  }

  @override
  Future<Bundle?> getBundleByID(String bundleID) async {
    final result = await _dbService.query('bundles', where: 'bundleID = ?', whereArgs: [bundleID]);
    if (result.isEmpty) return null;
    final data = Map<String, dynamic>.from(result.first);
    data['messageIDs'] = List<String>.from(jsonDecode(data['messageIDs'] as String));
    data['createdAt'] = DateTime.parse(data['createdAt'] as String);
    return Bundle.fromJson(data);
  }

  @override
  Future<List<Bundle>> getBundlesByHub(String hubID) async {
    final result = await _dbService.query(
      'bundles',
      where: 'sourceHub = ? OR destinationHub = ?',
      whereArgs: [hubID, hubID],
    );
    return result.map((json) {
      final data = Map<String, dynamic>.from(json);
      data['messageIDs'] = List<String>.from(jsonDecode(data['messageIDs'] as String));
      data['createdAt'] = DateTime.parse(data['createdAt'] as String);
      return Bundle.fromJson(data);
    }).toList();
  }

  @override
  Future<List<Bundle>> getBundlesByStatus(String status) async {
    final result = await _dbService.query('bundles', where: 'status = ?', whereArgs: [status]);
    return result.map((json) {
      final data = Map<String, dynamic>.from(json);
      data['messageIDs'] = List<String>.from(jsonDecode(data['messageIDs'] as String));
      data['createdAt'] = DateTime.parse(data['createdAt'] as String);
      return Bundle.fromJson(data);
    }).toList();
  }

  @override
  Future<void> updateBundleStatus(String bundleID, String status) async {
    await _dbService.update(
      'bundles',
      {'status': status},
      where: 'bundleID = ?',
      whereArgs: [bundleID],
    );
  }

  @override
  Future<void> deleteBun(String bundleID) async {
    await _dbService.delete('bundles', where: 'bundleID = ?', whereArgs: [bundleID]);
  }
}
