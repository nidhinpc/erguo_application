class ShopModel {
  final String id;
  final String name;
  final String place;
  final String phone;

  ShopModel({
    required this.id,
    required this.name,
    required this.place,
    required this.phone,
  });

  factory ShopModel.fromDoc(String id, Map<String, dynamic> data) {
    return ShopModel(
      id: id,
      name: data["name"] ?? "Unknown Shop",
      phone: data["phone"] ?? "No Phone",
      place: data["place"] ?? "Unknown Place",
    );
  }

  Map<String, dynamic> toMap() {
    return {"name": name, "place": place, "phone": phone};
  }
}
