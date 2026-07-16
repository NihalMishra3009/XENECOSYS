import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../repositories/impl/user_repository_impl.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final UserRepositoryImpl _userRepo = UserRepositoryImpl();
  SharedPreferences? _prefs;
  User? _currentUser;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    if (_currentUser == null && !(_prefs!.getBool('demoUserSeeded') ?? false)) {
      _currentUser = await _userRepo.createUser('Demo User', 'HUB-001');
      await _prefs!.setString('currentUserID', _currentUser!.uniqueID);
      await _prefs!.setBool('demoUserSeeded', true);
    }
  }

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<User> register(String name, String homeHubID) async {
    final user = await _userRepo.createUser(name, homeHubID);
    _currentUser = user;
    await (_prefs ??= await SharedPreferences.getInstance())
        .setString('currentUserID', user.uniqueID);
    return user;
  }

  Future<bool> login(String userID) async {
    final user = await _userRepo.getUserByID(userID);
    if (user == null) return false;
    _currentUser = user;
    await (_prefs ??= await SharedPreferences.getInstance()).setString('currentUserID', userID);
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    await (_prefs ??= await SharedPreferences.getInstance()).remove('currentUserID');
  }

  Future<User?> updateCurrentUser(User user) async {
    await _userRepo.updateUser(user);
    _currentUser = user;
    return user;
  }

  Future<User?> getStoredUser() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    final userID = prefs.getString('currentUserID');
    if (userID == null) return null;
    return _userRepo.getUserByID(userID);
  }

  Future<bool> hasStoredUser() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    return prefs.containsKey('currentUserID');
  }
}
