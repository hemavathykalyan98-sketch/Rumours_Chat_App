import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';

class ChatService {
  ChatService(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _messages(String room) =>
      _db.collection('rooms').doc(room).collection('messages');

  Stream<List<ChatMessage>> watchLatest(String room) {
    return _messages(room).orderBy('createdAt', descending: true).limit(30)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(ChatMessage.fromDoc).toList());
  }

  Future<List<ChatMessage>> olderThan(String room, DocumentSnapshot<Map<String, dynamic>> cursor) async {
    final page = await _messages(room).orderBy('createdAt', descending: true)
      .startAfterDocument(cursor).limit(30).get();
    return page.docs.map(ChatMessage.fromDoc).toList();
  }

  Future<void> send({
    required String room, required String senderId,
    required String senderName, required String text,
  }) async {
    final clean = text.trim();
    if (clean.isEmpty) return;
    final batch = _db.batch();
    final message = _messages(room).doc();
    batch.set(message, {
      'text': clean,
      'senderId': senderId,
      'senderName': senderName,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(_db.collection('rooms').doc(room), {
      'lastMessage': clean,
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
  }
}
