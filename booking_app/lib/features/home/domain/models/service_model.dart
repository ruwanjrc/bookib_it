class ServiceModel {
  final String id;
  final String name;
  final double price;
  final int durationInMinutes;

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.durationInMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'durationInMinutes': durationInMinutes,
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map, String docId) {
    return ServiceModel(
      id: docId,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      durationInMinutes: map['durationInMinutes'] ?? 0,
    );
  }
}