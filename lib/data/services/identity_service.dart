import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/room_identity.dart';

class IdentityService {
  static const _storageKey = 'rumour_room_identities_v1';
  static const _adjectives = ['Brave','Calm','Clever','Cosmic','Gentle','Lucky','Mighty','Quiet','Rapid','Witty'];
  static const _animals = ['Badger','Fox','Otter','Panda','Falcon','Koala','Tiger','Wolf','Dolphin','Hedgehog'];

  Future<RoomIdentity> forRoom(String roomCode) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = jsonDecode(prefs.getString(_storageKey) ?? '{}') as Map<String, dynamic>;
    final existing = stored[roomCode];
    if (existing is Map) {
      return RoomIdentity.fromJson(Map<String, dynamic>.from(existing));
    }

    // The randomuser UUID is used as the per-room identity seed. The display
    // name remains a privacy-friendly adjective + animal handle like the Figma.
    String seed;
    try {
      final response = await http.get(Uri.parse('https://randomuser.me/api/'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) throw Exception('Random identity service unavailable');
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      seed = body['results'][0]['login']['uuid'] as String;
    } catch (_) {
      seed = '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';
    }
    final hash = seed.codeUnits.fold<int>(17, (v, e) => (v * 31 + e) & 0x7fffffff);
    final identity = RoomIdentity(
      id: seed,
      nickname: '${_adjectives[hash % _adjectives.length]} ${_animals[(hash ~/ 13) % _animals.length]}',
    );
    stored[roomCode] = identity.toJson();
    await prefs.setString(_storageKey, jsonEncode(stored));
    return identity;
  }
}
