class User {
  String? userId;
  String? fullName;
  String? email;
  String? coin;
  String? dailyTries;
  String? standard;
  String? schoolCode;

  User({
    this.userId,
    this.fullName,
    this.email,
    this.coin,
    this.dailyTries,
    this.standard,
    this.schoolCode,
  });

  User.fromJson(Map<String, dynamic> json) {
    userId = json['user_id']?.toString();
    fullName = json['full_name'];
    email = json['email'];
    coin = json['coin']?.toString();
    dailyTries = json['daily_tries']?.toString();
    standard = json['standard']?.toString();
    schoolCode = json['school_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['full_name'] = fullName;
    data['email'] = email;
    data['coin'] = coin;
    data['daily_tries'] = dailyTries;
    data['standard'] = standard;
    data['school_code'] = schoolCode;
    return data;
  }
}
