import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  const ChatMessage({
    required this.id, required this.text, required this.senderId,
    required this.senderName, required this.createdAt,
  });

  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime? createdAt;

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final stamp = data['createdAt'];
    return ChatMessage(
      id: doc.id,
      text: data['text'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? 'Anonymous',
      createdAt: stamp is Timestamp ? stamp.toDate() : null,
    );
  }
}
