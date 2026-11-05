class RoomIdentity {
  const RoomIdentity({required this.id, required this.nickname});
  final String id;
  final String nickname;

  Map<String, String> toJson() => {'id': id, 'nickname': nickname};
  factory RoomIdentity.fromJson(Map<String, dynamic> json) => RoomIdentity(
    id: json['id'] as String, nickname: json['nickname'] as String,
  );
}
