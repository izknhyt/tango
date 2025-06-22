class TagStats {
  int totalAttempts;
  int totalWrong;

  TagStats({this.totalAttempts = 0, this.totalWrong = 0});

  factory TagStats.fromMap(Map<dynamic, dynamic> map) {
    return TagStats(
      totalAttempts: (map['totalAttempts'] as int?) ?? 0,
      totalWrong: (map['totalWrong'] as int?) ?? 0,
    );
  }

  Map<String, int> toMap() => {
        'totalAttempts': totalAttempts,
        'totalWrong': totalWrong,
      };
}
