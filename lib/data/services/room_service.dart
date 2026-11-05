import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomService {
  RoomService(this._db);
  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _rooms => _db.collection('rooms');

  Future<String> createRoom() async {
    for (var attempt = 0; attempt < 8; attempt++) {
      final code = (100000 + Random.secure().nextInt(900000)).toString();
      final ref = _rooms.doc(code);
      final snap = await ref.get();
      if (!snap.exists) {
        await ref.set({
          'code': code,
          'createdAt': FieldValue.serverTimestamp(),
          'memberCount': 0,
          'lastMessage': null,
        });
        return code;
      }
    }
    throw Exception('Could not allocate a room code. Please try again.');
  }

  Future<bool> roomExists(String code) async => (await _rooms.doc(code).get()).exists;

  Future<void> registerMember(String code, String userId, String nickname) async {
    final room = _rooms.doc(code);
    final member = room.collection('members').doc(userId);
    await _db.runTransaction((transaction) async {
      final existing = await transaction.get(member);
      transaction.set(member, {
        'nickname': nickname,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!existing.exists) {
        transaction.set(room, {'memberCount': FieldValue.increment(1)}, SetOptions(merge: true));
      }
    });
  }
}
