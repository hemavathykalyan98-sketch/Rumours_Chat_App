import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/room_identity.dart';
import '../../data/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.roomCode, required this.identity});
  final String roomCode;
  final RoomIdentity identity;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  late final ChatService _chat;
  List<ChatMessage> _older = [];
  DocumentSnapshot<Map<String, dynamic>>? _cursor;
  bool _loadingOlder = false;
  bool _hasMore = true;
  bool _initialCursorSet = false;

  @override
  void initState() {
    super.initState();
    _chat = ChatService(FirebaseFirestore.instance);
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 160) _loadOlder();
  }

  Future<void> _loadOlder() async {
    if (_loadingOlder || !_hasMore || _cursor == null) return;
    setState(() => _loadingOlder = true);
    try {
      final page = await _chat.olderThan(widget.roomCode, _cursor!);
      if (page.isEmpty) _hasMore = false;
      else {
        _older.addAll(page);
        final lastPageId = page.last.id;
        _cursor = await FirebaseFirestore.instance.collection('rooms').doc(widget.roomCode)
          .collection('messages').doc(lastPageId).get();
        if (page.length < 30) _hasMore = false;
      }
    } finally {
      if (mounted) setState(() => _loadingOlder = false);
    }
  }

  Future<void> _send() async {
    final value = _controller.text;
    if (value.trim().isEmpty) return;
    _controller.clear();
    await _chat.send(room: widget.roomCode, senderId: widget.identity.id,
      senderName: widget.identity.nickname, text: value);
  }

  @override
  void dispose() { _controller.dispose(); _scroll.dispose(); super.dispose(); }

  bool _sameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background, centerTitle: true,
        leading: IconButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
          icon: const CircleAvatar(radius: 17, backgroundColor: Color(0xFF202A38),
            child: Icon(Icons.chevron_left, color: Colors.white))),
        title: Column(children: [
          Text('Room #${widget.roomCode}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const Text('Anonymous chat', style: TextStyle(fontSize: 10, color: AppColors.muted)),
        ]),
        actions: const [Padding(padding: EdgeInsets.only(right: 18), child: CircleAvatar(radius: 12, backgroundColor: Colors.black))],
      ),
      body: Column(children: [
        Expanded(
          child: StreamBuilder<List<ChatMessage>>(
            stream: _chat.watchLatest(widget.roomCode),
            builder: (context, snapshot) {
              final latest = snapshot.data ?? [];
              if (snapshot.hasError) return const Center(child: Text('Could not load messages.'));
              if (latest.isNotEmpty && !_initialCursorSet) {
                // Query is newest-first; the last document is the oldest item
                // in this live page and therefore the next-page cursor.
                _initialCursorSet = true;
                _setCursor(latest.last.id);
              }
              final messages = [...latest, ..._older];
              if (messages.isEmpty && !snapshot.hasData) return const Center(child: CircularProgressIndicator());
              return ListView.builder(
                controller: _scroll, reverse: true, padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                itemCount: messages.length + (_loadingOlder ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_loadingOlder && index == messages.length) return const Padding(
                    padding: EdgeInsets.all(12), child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))));
                  final message = messages[index];
                  final previous = index + 1 < messages.length ? messages[index + 1] : null;
                  final isMine = message.senderId == widget.identity.id;
                  final showDate = previous == null || !_sameDay(message.createdAt, previous.createdAt);
                  return Column(children: [
                    if (showDate) _DatePill(date: message.createdAt),
                    _MessageBubble(message: message, isMine: isMine),
                  ]);
                },
              );
            },
          ),
        ),
        SafeArea(top: false, child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Row(children: [
            Expanded(child: TextField(controller: _controller, minLines: 1, maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Type a message', contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 13)),
              onSubmitted: (_) => _send())),
            const SizedBox(width: 8),
            Material(color: AppColors.lime, shape: const CircleBorder(),
              child: InkWell(customBorder: const CircleBorder(), onTap: _send,
                child: const SizedBox(width: 42, height: 42, child: Icon(Icons.send_rounded, color: Colors.black, size: 19)))),
          ]),
        )),
      ]),
    );
  }

  Future<void> _setCursor(String id) async {
    if (_cursor?.id == id) return;
    final doc = await FirebaseFirestore.instance.collection('rooms').doc(widget.roomCode)
      .collection('messages').doc(id).get();
    if (mounted) setState(() => _cursor = doc);
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({required this.date});
  final DateTime? date;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: DecoratedBox(
      decoration: BoxDecoration(color: const Color(0xFF202A38), borderRadius: BorderRadius.circular(20)),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(date == null ? 'Today' : DateFormat('d MMM yyyy').format(date!),
          style: const TextStyle(fontSize: 9, color: AppColors.muted))),
    ),
  );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});
  final ChatMessage message;
  final bool isMine;
  @override
  Widget build(BuildContext context) {
    final time = message.createdAt == null ? '' : DateFormat('HH:mm').format(message.createdAt!);
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .78),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
            if (!isMine) Padding(padding: const EdgeInsets.only(left: 2, bottom: 4),
              child: Text('@${message.senderName}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 7),
              decoration: BoxDecoration(
                color: isMine ? AppColors.lime : AppColors.incoming,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(message.text, style: TextStyle(color: isMine ? Colors.black : AppColors.text, fontSize: 12, height: 1.35)),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(color: isMine ? Colors.black54 : AppColors.muted, fontSize: 9)),
              ]),
            ),
            if (isMine) const Padding(padding: EdgeInsets.only(right: 2, top: 3),
              child: Text('You', style: TextStyle(fontSize: 9, color: AppColors.text))),
          ]),
        ),
      ),
    );
  }
}
