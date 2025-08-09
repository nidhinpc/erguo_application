// --- Payment Model ---
class PaymentModel {
  final String id;
  final String workerId;
  final String userId;
  final int amount;
  final String description;
  final bool paid;

  PaymentModel({
    required this.id,
    required this.workerId,
    required this.userId,
    required this.amount,
    required this.description,
    required this.paid,
  });

  factory PaymentModel.fromDoc(String id, Map<String, dynamic> data) {
    return PaymentModel(
      id: id,
      workerId: data['workerId'] ?? '',
      userId: data['userId'] ?? '',
      amount: data['amount'] ?? 0,
      description: data['description'] ?? '',
      paid: data['paid'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    "workerId": workerId,
    "userId": userId,
    "amount": amount,
    "description": description,
    "paid": paid,
  };
}
