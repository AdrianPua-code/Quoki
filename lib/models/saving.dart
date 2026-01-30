class Saving {
  final String id;
  final String goalName;
  double currentAmount;
  final double targetAmount;

  Saving({
    required this.id,
    required this.goalName,
    required this.currentAmount,
    required this.targetAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalName': goalName,
      'currentAmount': currentAmount,
      'targetAmount': targetAmount,
    };
  }

  factory Saving.fromJson(Map<String, dynamic> json) {
    return Saving(
      id: json['id'],
      goalName: json['goalName'],
      currentAmount: json['currentAmount'],
      targetAmount: json['targetAmount'],
    );
  }

  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0.0;
}
