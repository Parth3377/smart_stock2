class ProductModel {
  final String id;
  final String name;
  final String image;
  final double price;
  final String description;

  ProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.description,
  });

  /// Convert Firebase/JSON → ProductModel (future use)
  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
    );
  }

  /// Convert ProductModel → Map (for Firebase later)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'price': price,
      'description': description,
    };
  }
}
