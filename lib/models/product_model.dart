class ProductModel {
  final String id;
  final String name;
  final String image;
  final double price;
  final String description;
  final String category;

  ProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.description,
    required this.category,
  });

  /// Firebase/JSON → ProductModel
  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      category: map['category'] ?? 'General', // ✅ FIXED
    );
  }

  /// ProductModel → Firebase Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'price': price,
      'description': description,
      'category': category, // ✅ IMPORTANT
    };
  }
}
