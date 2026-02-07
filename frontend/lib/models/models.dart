// lib/models/user_model.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'client', 'opticien', 'admin'
  final bool isActive;
  final DateTime createdAt;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'client',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'profileImage': profileImage,
    };
  }
}

// lib/models/opticien_model.dart

class OpticienModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final bool isVerified;
  final double rating;
  final int totalOrders;
  final DateTime joinedDate;
  final String? logo;

  OpticienModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.isVerified,
    required this.rating,
    required this.totalOrders,
    required this.joinedDate,
    this.logo,
  });

  factory OpticienModel.fromJson(Map<String, dynamic> json) {
    return OpticienModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      isVerified: json['isVerified'] ?? false,
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalOrders: json['totalOrders'] ?? 0,
      joinedDate: DateTime.parse(json['joinedDate'] ?? DateTime.now().toString()),
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'isVerified': isVerified,
      'rating': rating,
      'totalOrders': totalOrders,
      'joinedDate': joinedDate.toIso8601String(),
      'logo': logo,
    };
  }
}

// lib/models/insurance_model.dart

class InsuranceModel {
  final String id;
  final String name;
  final String code;
  final double coveragePercentage;
  final double maxCoverage;
  final bool isActive;
  final String? logo;

  InsuranceModel({
    required this.id,
    required this.name,
    required this.code,
    required this.coveragePercentage,
    required this.maxCoverage,
    required this.isActive,
    this.logo,
  });

  factory InsuranceModel.fromJson(Map<String, dynamic> json) {
    return InsuranceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      coveragePercentage: (json['coveragePercentage'] ?? 0.0).toDouble(),
      maxCoverage: (json['maxCoverage'] ?? 0.0).toDouble(),
      isActive: json['isActive'] ?? true,
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'coveragePercentage': coveragePercentage,
      'maxCoverage': maxCoverage,
      'isActive': isActive,
      'logo': logo,
    };
  }
}

// lib/models/statistics_model.dart

class StatisticsModel {
  final int totalUsers;
  final int totalOpticiens;
  final int totalOrders;
  final double totalRevenue;
  final int pendingOrders;
  final int completedOrders;
  final List<MonthlyData> monthlyRevenue;
  final List<CategoryData> ordersByCategory;

  StatisticsModel({
    required this.totalUsers,
    required this.totalOpticiens,
    required this.totalOrders,
    required this.totalRevenue,
    required this.pendingOrders,
    required this.completedOrders,
    required this.monthlyRevenue,
    required this.ordersByCategory,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalUsers: json['totalUsers'] ?? 0,
      totalOpticiens: json['totalOpticiens'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0.0).toDouble(),
      pendingOrders: json['pendingOrders'] ?? 0,
      completedOrders: json['completedOrders'] ?? 0,
      monthlyRevenue: (json['monthlyRevenue'] as List? ?? [])
          .map((e) => MonthlyData.fromJson(e))
          .toList(),
      ordersByCategory: (json['ordersByCategory'] as List? ?? [])
          .map((e) => CategoryData.fromJson(e))
          .toList(),
    );
  }
}

class MonthlyData {
  final String month;
  final double revenue;

  MonthlyData({required this.month, required this.revenue});

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      month: json['month'] ?? '',
      revenue: (json['revenue'] ?? 0.0).toDouble(),
    );
  }
}

class CategoryData {
  final String category;
  final int count;

  CategoryData({required this.category, required this.count});

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      category: json['category'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}