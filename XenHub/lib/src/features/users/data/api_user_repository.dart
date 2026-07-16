import '../../../core/api/hub_api_client.dart';
import '../domain/user_account.dart';
import '../domain/user_repository.dart';

class ApiUserRepository implements UserRepository {
  ApiUserRepository(this._client);

  final HubApiClient _client;

  @override
  Future<UserAccount> createUser(UserAccount user) async {
    final json = await _client.postObject(
      'users',
      body: {
        'fullName': user.fullName,
        'email': user.email,
        'phone': user.phone,
      },
    );
    return _fromJson(json);
  }

  @override
  Future<void> deleteUser(int id) => _client.delete('users/$id');

  @override
  Future<List<UserAccount>> listUsers() async {
    final json = await _client.getObject('users');
    final items = (json['items'] as List? ?? const []);
    return items
        .cast<Map<String, dynamic>>()
        .map(_fromJson)
        .toList(growable: false);
  }

  @override
  Future<UserAccount> updateUser(UserAccount user) async {
    final json = await _client.putObject(
      'users/${user.id}',
      body: {
        'fullName': user.fullName,
        'email': user.email,
        'phone': user.phone,
      },
    );
    return _fromJson(json);
  }

  UserAccount _fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'] as int?,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
