class PaymentModel {
  final String id;
  final String workerId;
  final String userId;
  final int amount;
  final String description;
  final bool paid;
  final int bookId; // link to a booking

  PaymentModel({
    required this.id,
    required this.workerId,
    required this.userId,
    required this.amount,
    required this.description,
    required this.paid,
    required this.bookId,
  });

  factory PaymentModel.fromDoc(String id, Map<String, dynamic> data) {
    return PaymentModel(
      id: id,
      workerId: data['workerId']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      amount: data['amount'] is int
          ? data['amount']
          : int.tryParse(data['amount']?.toString() ?? '0') ?? 0,
      description: data['description']?.toString() ?? '',
      paid: data['paid'] ?? false,
      bookId: (data['bookId'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() => {
    "workerId": workerId,
    "userId": userId,
    "amount": amount,
    "description": description,
    "paid": paid,
    "bookId": bookId,
  };
}
