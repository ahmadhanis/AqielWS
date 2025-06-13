class Reward {
  final String rewardId;
  final String rewardName;
  final String description;
  final String category;
  final String provider;
  final String coinCost;
  final String stockQuantity;

  Reward({
    required this.rewardId,
    required this.rewardName,
    required this.description,
    required this.category,
    required this.provider,
    required this.coinCost,
    required this.stockQuantity,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      rewardId: json['reward_id'],
      rewardName: json['reward_name'],
      description: json['description'],
      category: json['category'],
      provider: json['provider'],
      coinCost: json['coin_cost'],
      stockQuantity: json['stock_quantity'],
    );
  }
}
