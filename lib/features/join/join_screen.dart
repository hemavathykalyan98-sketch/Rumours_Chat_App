import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_mark.dart';
import '../../data/services/identity_service.dart';
import '../../data/services/room_service.dart';
import '../identity/identity_screen.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});
  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final _code = TextEditingController();
  final _rooms = RoomService(FirebaseFirestore.instance);
  bool _busy = false;

  Future<void> _enter({required bool create}) async {
    if (_busy) return;
    final code = _code.text.trim();
    if (!create && !RegExp(r'^\d{6}$').hasMatch(code)) {
      _message('Enter the 6-digit room code.');
      return;
    }
    setState(() => _busy = true);
    try {
      await FirebaseAuth.instance.signInAnonymously();
      final room = create ? await _rooms.createRoom() : code;
      if (!create && !await _rooms.roomExists(room)) {
        _message('That room could not be found.');
        return;
      }
      final identity = await IdentityService().forRoom(room);
      await _rooms.registerMember(room, identity.id, identity.nickname);
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => IdentityScreen(roomCode: room, identity: identity),
      ));
    } catch (e) {
      _message('Unable to join right now. Check your connection and Firebase setup.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));

  @override
  void dispose() { _code.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 54),
                  const BrandMark(size: 54),
                  const Spacer(flex: 3),
                  Text('Join A Room', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  const Text('Enter the code to join the anon chat room',
                    textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  const SizedBox(height: 26),
                  TextField(
                    controller: _code,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(letterSpacing: 10, fontSize: 20, fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(hintText: '— — — — — —', counterText: ''),
                    onSubmitted: (_) => _enter(create: false),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: _busy ? null : () => _enter(create: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lime, foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _busy ? const CircularProgressIndicator() : const Text('Join room', style: TextStyle(fontWeight: FontWeight.w700)),
                    )),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _busy ? null : () => _enter(create: true),
                    child: const Text('Create a new room', style: TextStyle(color: AppColors.lime, fontWeight: FontWeight.w700)),
                  ),
                  const Spacer(flex: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
