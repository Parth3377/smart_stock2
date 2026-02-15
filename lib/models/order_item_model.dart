class OrderItemModel {
  final String id;
  final String name;
  final String image;
  final double price;
  int quantity;

  OrderItemModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;
}
