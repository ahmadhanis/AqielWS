class Leaderboard {
  final String rankId;
  final String userId;
  final String gameTitle;
  final int coins;
  final String lastUpdate;
  final String fullName;
  final String schoolCode;
  final String standard;

  Leaderboard({
    required this.rankId,
    required this.userId,
    required this.gameTitle,
    required this.coins,
    required this.lastUpdate,
    required this.fullName,
    required this.schoolCode,
    required this.standard,
  });

  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    return Leaderboard(
      rankId: json['rankid'] ?? '',
      userId: json['user_id'] ?? '',
      gameTitle: json['game_title'] ?? '',
      coins: int.parse(json['coins'].toString()),
      lastUpdate: json['lastupdate'] ?? '',
      fullName: json['full_name'] ?? 'Anonymous',
      schoolCode: json['school_code'] ?? '',
      standard: json['standard'] ?? '',
    );
  }
}
