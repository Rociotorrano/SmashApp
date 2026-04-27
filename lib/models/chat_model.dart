import 'package:pantheon/models/user_model.dart';

class ConnectionModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime createdAt;
  final UserModel otherUser;
  final String? lastMessage;
  final bool isTemporary;

  ConnectionModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
    required this.otherUser,
    this.lastMessage,
    this.isTemporary = false,
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    return ConnectionModel(
      id: json['id'],
      user1Id: json['usuario_1_id'],
      user2Id: json['usuario_2_id'],
      createdAt: DateTime.parse(json['creado_en']),
      otherUser: UserModel.fromJson(json['otro_usuario']),
      lastMessage: json['ultimo_mensaje']?['mensaje'],
    );
  }
}

class MessageModel {
  final String id;
  final String connectionId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime sentAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.connectionId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.sentAt,
    required this.isRead,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      connectionId: json['conexion_id'],
      senderId: json['emisor_id'],
      receiverId: json['receptor_id'],
      content: json['mensaje'],
      sentAt: DateTime.parse(json['enviado_en']),
      isRead: json['leido'] == true || json['leido'] == 1,
    );
  }

  bool get isMine {
    // This logic usually depends on current user ID context.
    // We'll handle this in UI or with a helper if we have access to current ID.
    // For now, simple model.
    return false;
  }
}
