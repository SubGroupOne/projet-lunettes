class Product {
  final String name;
  final String desc;
  final String price;
  final String image; // local asset path fallback
  final String? imageUrl; // optional network image (preferred)
  final double rating;
  final int? discountPercent;

  final String? tryOnAsset; // transparent PNG for virtual try-on

  Product({
    required this.name,
    required this.desc,
    required this.price,
    required this.image,
    this.imageUrl,
    this.tryOnAsset,
    this.rating = 4.5,
    this.discountPercent,
  });

  Map<String, String> toMap() => {
    'name': name,
    'desc': desc,
    'price': price,
    'image': imageUrl ?? image,
  };
}

// Eyeglasses products
class EyeglassesProducts {
  static final men = [
    Product(
      name: 'Lumina Classic',
      desc: 'Aviateur. Noir Onyx',
      price: '45 000 F',
      image: 'assets/photos/men_accessories_embellished_1.jpeg',
      tryOnAsset: 'assets/blue_sunglasses.png',
      rating: 4.8,
      discountPercent: 10,
    ),
    Product(
      name: 'Minimalist Slate',
      desc: 'Carré. Anthracite',
      price: '38 000 F',
      image: 'assets/photos/men_accessories_embellished_2.jpeg',
      tryOnAsset: 'assets/orange_sunglasses.png',
      rating: 4.5,
    ),
    Product(
      name: 'Harbour Frame',
      desc: 'Rectangle léger',
      price: '42 000 F',
      image: 'assets/photos/men_blue_light_clear.jpeg',
      rating: 4.6,
      discountPercent: 5,
    ),
    Product(
      name: 'Metro Edge',
      desc: 'Carré. Minimal',
      price: '37 000 F',
      image: 'assets/photos/men_collar_embellished.jpeg',
      rating: 4.4,
    ),
    Product(
      name: 'Aero Slim',
      desc: 'Ultra-light',
      price: '50 000 F',
      image: 'assets/photos/men_vintage_collar.jpeg',
      rating: 4.7,
    ),
    Product(
      name: 'Classic Noir',
      desc: 'Intemporel',
      price: '48 000 F',
      image: 'assets/photos/glasses_photo_03.jpeg',
      tryOnAsset: 'assets/glasses.png',
      rating: 4.9,
      discountPercent: 15,
    ),
    Product(
      name: 'Urban Pilot',
      desc: 'Aviateur revu',
      price: '55 000 F',
      image: 'assets/photos/glasses_photo_04.jpeg',
      rating: 4.3,
    ),
    Product(
      name: 'Contour M',
      desc: 'Carré profile',
      price: '35 000 F',
      image: 'assets/photos/glasses_photo_10.jpeg',
      rating: 4.5,
    ),
  ];

  static final women = [
    Product(
      name: 'Retro Gold',
      desc: 'Rond. Or 18k',
      price: '52 000 F',
      image: 'assets/photos/glasses_photo_01.jpeg',
      tryOnAsset: 'assets/pink_gold_glasses.png',
      rating: 4.9,
      discountPercent: 20,
    ),
    Product(
      name: 'Tortoise Charm',
      desc: 'Ovale. Écaille',
      price: '41 000 F',
      image: 'assets/photos/glasses_photo_02.jpeg',
      tryOnAsset: 'assets/tortoise_glasses.png',
      rating: 4.7,
    ),
    Product(
      name: 'Pearl Curve',
      desc: 'Féminin doux',
      price: '46 000 F',
      image: 'assets/photos/glasses_photo_11.jpeg',
      rating: 4.6,
      discountPercent: 8,
    ),
    Product(
      name: 'Silk Frame',
      desc: 'Mat et fin',
      price: '39 000 F',
      image: 'assets/photos/glasses_photo_12.jpeg',
      rating: 4.5,
    ),
    Product(
      name: 'Glam Cat',
      desc: 'Cat-eye sophistiqué',
      price: '58 000 F',
      image: 'assets/photos/glasses_photo_13.jpeg',
      rating: 4.8,
    ),
    Product(
      name: 'Luna Petite',
      desc: 'Léger & charmant',
      price: '34 000 F',
      image: 'assets/photos/glasses_photo_14.jpeg',
      rating: 4.4,
      discountPercent: 12,
    ),
    Product(
      name: 'Velvet Rim',
      desc: 'Texture douce',
      price: '44 000 F',
      image: 'assets/photos/men_blue_light_clear.jpeg',
      rating: 4.6,
    ),
    Product(
      name: 'Aura Oval',
      desc: 'Ovale moderne',
      price: '49 000 F',
      image: 'assets/photos/men_collar_embellished.jpeg',
      rating: 4.7,
    ),
  ];

  static final kids = [
    Product(
      name: 'Mini Clear',
      desc: 'Pour enfants',
      price: '20 000 F',
      image: 'assets/photos/men_accessories_embellished_1.jpeg',
      rating: 4.5,
    ),
    Product(
      name: 'Bright Kid',
      desc: 'Coloré & solide',
      price: '22 000 F',
      image: 'assets/photos/men_accessories_embellished_2.jpeg',
      rating: 4.6,
      discountPercent: 5,
    ),
    Product(
      name: 'Sunny Tot',
      desc: 'Protection UV',
      price: '25 000 F',
      image: 'assets/photos/glasses_photo_10.jpeg',
      rating: 4.4,
    ),
    Product(
      name: 'Play Frame',
      desc: 'Flexible',
      price: '18 000 F',
      image: 'assets/photos/glasses_photo_03.jpeg',
      rating: 4.7,
    ),
    Product(
      name: 'Tiny Pilot',
      desc: 'Mini-aviator',
      price: '24 000 F',
      image: 'assets/photos/glasses_photo_04.jpeg',
      rating: 4.5,
    ),
    Product(
      name: 'Color Pop',
      desc: 'Vif & fun',
      price: '21 000 F',
      image: 'assets/photos/men_vintage_collar.jpeg',
      rating: 4.3,
    ),
    Product(
      name: 'Pocket Jr',
      desc: 'Robuste',
      price: '19 000 F',
      image: 'assets/photos/glasses_photo_11.jpeg',
      rating: 4.6,
    ),
    Product(
      name: 'Rainbow',
      desc: 'Design enfant',
      price: '23 000 F',
      image: 'assets/photos/glasses_photo_12.jpeg',
      rating: 4.8,
    ),
  ];
}

// Sunglasses products
class SunglassesProducts {
  static final men = [
    Product(
      name: 'Ocean Sport',
      desc: 'Sport. Polarized',
      price: '60 000 F',
      image: 'assets/photos/men_accessories_embellished_1.jpeg',
      rating: 4.8,
      discountPercent: 10,
    ),
    Product(
      name: 'Coast Driver',
      desc: 'Polarized pilot',
      price: '68 000 F',
      image: 'assets/photos/men_accessories_embellished_2.jpeg',
      rating: 4.9,
    ),
    Product(
      name: 'Shoreline',
      desc: 'Lunettes de ville',
      price: '58 000 F',
      image: 'assets/photos/men_blue_light_clear.jpeg',
      rating: 4.6,
      discountPercent: 7,
    ),
    Product(
      name: 'Shadow Runner',
      desc: 'Sport léger',
      price: '54 000 F',
      image: 'assets/photos/men_collar_embellished.jpeg',
      rating: 4.5,
    ),
    Product(
      name: 'Metro Shade',
      desc: 'Design urbain',
      price: '62 000 F',
      image: 'assets/photos/men_vintage_collar.jpeg',
      rating: 4.7,
      discountPercent: 12,
    ),
    Product(
      name: 'Polarix',
      desc: 'Haute protection',
      price: '75 000 F',
      image: 'assets/photos/glasses_photo_03.jpeg',
      rating: 4.9,
    ),
    Product(
      name: 'Field Lens',
      desc: 'Verres résistants',
      price: '70 000 F',
      image: 'assets/photos/glasses_photo_04.jpeg',
      rating: 4.4,
      discountPercent: 15,
    ),
    Product(
      name: 'Edge Sun',
      desc: 'Carré renforcé',
      price: '59 000 F',
      image: 'assets/photos/glasses_photo_10.jpeg',
      rating: 4.6,
    ),
  ];

  static final women = [
    Product(
      name: 'Sun Luxe',
      desc: 'Cat-eye. Or',
      price: '72 000 F',
      image: 'assets/photos/glasses_photo_01.jpeg',
      rating: 4.9,
      discountPercent: 18,
    ),
    Product(
      name: 'Gala Shine',
      desc: 'Luxe & glamour',
      price: '85 000 F',
      image: 'assets/photos/glasses_photo_02.jpeg',
      rating: 4.8,
    ),
    Product(
      name: 'Mirage',
      desc: 'Verres miroirs',
      price: '68 000 F',
      image: 'assets/photos/glasses_photo_11.jpeg',
      rating: 4.7,
      discountPercent: 6,
    ),
    Product(
      name: 'Flora Shade',
      desc: 'Féminin floral',
      price: '64 000 F',
      image: 'assets/photos/glasses_photo_12.jpeg',
      rating: 4.6,
    ),
    Product(
      name: 'Velvet Sun',
      desc: 'Élégance urbaine',
      price: '77 000 F',
      image: 'assets/photos/glasses_photo_13.jpeg',
      rating: 4.8,
      discountPercent: 14,
    ),
    Product(
      name: 'Sapphire',
      desc: 'Teinte bleutée',
      price: '69 000 F',
      image: 'assets/photos/glasses_photo_14.jpeg',
      rating: 4.5,
    ),
    Product(
      name: 'Rose Gold',
      desc: 'Tendance',
      price: '80 000 F',
      image: 'assets/photos/men_blue_light_clear.jpeg',
      rating: 4.9,
    ),
    Product(
      name: 'Lumière',
      desc: 'Léger & chic',
      price: '71 000 F',
      image: 'assets/photos/men_collar_embellished.jpeg',
      rating: 4.7,
    ),
  ];

  static final kids = [
    Product(
      name: 'Sunny Jr',
      desc: 'Coloré pour enfants',
      price: '25 000 F',
      image: 'assets/photos/men_vintage_collar.jpeg',
      rating: 4.6,
      discountPercent: 10,
    ),
    Product(
      name: 'Beach Buddy',
      desc: 'UV safe',
      price: '27 000 F',
      image: 'assets/photos/glasses_photo_10.jpeg',
      rating: 4.7,
    ),
    Product(
      name: 'Tiny Ray',
      desc: 'Petits explorateurs',
      price: '26 000 F',
      image: 'assets/photos/glasses_photo_03.jpeg',
      rating: 4.5,
      discountPercent: 8,
    ),
    Product(
      name: 'Fun Shield',
      desc: 'Robuste & fun',
      price: '24 000 F',
      image: 'assets/photos/glasses_photo_04.jpeg',
      rating: 4.8,
    ),
    Product(
      name: 'Mini Shield',
      desc: 'Protection junior',
      price: '23 000 F',
      image: 'assets/photos/glasses_photo_11.jpeg',
      rating: 4.4,
    ),
    Product(
      name: 'Play Sun',
      desc: 'Couleurs vives',
      price: '22 000 F',
      image: 'assets/photos/glasses_photo_12.jpeg',
      rating: 4.6,
      discountPercent: 5,
    ),
    Product(
      name: 'Sunny Pop',
      desc: 'Petit et léger',
      price: '21 000 F',
      image: 'assets/photos/glasses_photo_13.jpeg',
      rating: 4.7,
    ),
    Product(
      name: 'Kiddie Cool',
      desc: 'Style enfantin',
      price: '28 000 F',
      image: 'assets/photos/glasses_photo_14.jpeg',
      rating: 4.9,
    ),
  ];
}
