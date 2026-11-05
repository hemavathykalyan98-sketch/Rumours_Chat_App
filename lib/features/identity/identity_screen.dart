import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/room_identity.dart';
import '../chat/chat_screen.dart';

class IdentityScreen extends StatelessWidget {
  const IdentityScreen({super.key, required this.roomCode, required this.identity});
  final String roomCode;
  final RoomIdentity identity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Row(children: [
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, size: 18)),
                    const Spacer(),
                    Column(children: [
                      Text('Room #$roomCode', style: const TextStyle(fontWeight: FontWeight.w700)),
                      const Text('Anonymous room created by hema', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                    ]),
                    const Spacer(),
                    const SizedBox(width: 44),
                  ]),
                  const Spacer(),
                  Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
                    decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(14)),
                    child: Column(children: [
                      const Text('For this room, you are', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                      const SizedBox(height: 14),
                      Text(identity.nickname, textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFE1ED36), fontSize: 34, height: 1.0, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 16),
                      const Text('This is your anonymous identifier, visible only to others in this room.',
                        textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 11)),
                    ]),
                  ),
                  const Spacer(),
                  SizedBox(width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (_) => ChatScreen(roomCode: roomCode, identity: identity))),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.lime, foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Acknowledge and continue', style: TextStyle(fontWeight: FontWeight.w800)),
                    )),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
