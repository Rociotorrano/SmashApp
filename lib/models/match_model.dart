class MatchModel {
  final String id;
  final String player1Id;
  final String player2Id;
  final String status;
  final DateTime createdAt;

  MatchModel({
    required this.id,
    required this.player1Id,
    required this.player2Id,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'player1Id': player1Id,
    'player2Id': player2Id,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };

  factory MatchModel.fromJson(Map<String, dynamic> json) => MatchModel(
    id: json['id'] as String,
    player1Id: json['player1Id'] as String,
    player2Id: json['player2Id'] as String,
    status: json['status'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  MatchModel copyWith({
    String? id,
    String? player1Id,
    String? player2Id,
    String? status,
    DateTime? createdAt,
  }) => MatchModel(
    id: id ?? this.id,
    player1Id: player1Id ?? this.player1Id,
    player2Id: player2Id ?? this.player2Id,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
}
