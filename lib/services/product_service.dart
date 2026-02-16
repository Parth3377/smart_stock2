import '../models/product_model.dart';

class ProductService {
  /// Temporary local product list
  /// Later this will come from Firebase
  static List<ProductModel> getProducts() {
    return [
      ProductModel(
        id: '1',
        name: 'Security Labels',
        description: 'High quality security labels for branding & protection.',
        image: 'assets/products/label1.png',
        price: 120,
        category: 'Labels',
      ),
      ProductModel(
        id: '2',
        name: 'QR Stickers',
        description: 'Durable QR code stickers for scanning solutions.',
        image: 'assets/products/qr1.png',
        price: 250,
        category: 'QR',
      ),
      ProductModel(
        id: '3',
        name: 'QR Codes',
        description: 'Custom QR codes for smart tracking.',
        image: 'assets/products/qr2.png',
        price: 340,
        category: 'QR',
      ),
      ProductModel(
        id: '4',
        name: 'Brand Stickers',
        description: 'Premium stickers for brand visibility.',
        image: 'assets/products/sticker.png',
        price: 499,
        category: 'Branding',
      ),
      ProductModel(
        id: '5',
        name: 'Holographic Stickers',
        description: 'Tamper-proof holographic protection labels.',
        image: 'assets/products/hologram.png',
        price: 180,
        category: 'Hologram',
      ),
      ProductModel(
        id: '6',
        name: 'Premium Labels',
        description: 'High-end polyester product labels.',
        image: 'assets/products/label2.png',
        price: 299,
        category: 'Labels',
      ),
    ];
  }
}
