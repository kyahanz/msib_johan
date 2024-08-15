class ExpenseModel {
  final int id;
  final int userId;
  final int categoryId;
  final int walletId;
  final String name;
  final String amount;
  final DateTime time;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.walletId,
    required this.name,
    required this.amount,
    required this.time,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      walletId: json['wallet_id'],
      name: json['name'],
      amount: json['amount'],
      time: DateTime.parse(json['time']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
