// lib/models/glasses_model.dart

class GlassesModel {
  final String id;
  final String name;
  final String brand;
  final String category; // 'homme', 'femme', 'enfant', 'sport', 'solaire'
  final double price;
  final String color;
  final String material;
  final List<String> images; // Multiple images pour rotation 3D
  final String mainImage;
  final bool isAvailable;
  final String description;
  final Map<String, dynamic>? specifications;

  GlassesModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.color,
    required this.material,
    required this.images,
    required this.mainImage,
    required this.isAvailable,
    required this.description,
    this.specifications,
  });

  factory GlassesModel.fromJson(Map<String, dynamic> json) {
    return GlassesModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      category: json['category'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      color: json['color'] ?? '',
      material: json['material'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      mainImage: json['mainImage'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      description: json['description'] ?? '',
      specifications: json['specifications'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'price': price,
      'color': color,
      'material': material,
      'images': images,
      'mainImage': mainImage,
      'isAvailable': isAvailable,
      'description': description,
      'specifications': specifications,
    };
  }
}