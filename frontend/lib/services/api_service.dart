// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../models/glasses_models.dart';

class ApiService {
  // À MODIFIER : Remplace par l'URL de l'API de tes collègues
  static const String baseUrl = 'http://localhost:3000';

  // Token d'authentification (à stocker de manière sécurisée)
  static String? _authToken;

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }

  // ============ GESTION DES UTILISATEURS ============

  static Future<List<UserModel>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur de chargement des utilisateurs');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  static Future<bool> updateUserStatus(String userId, bool isActive) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/users/$userId/status'),
        headers: _getHeaders(),
        body: json.encode({'isActive': isActive}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: _getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ============ GESTION DES OPTICIENS ============

  static Future<List<OpticienModel>> getOpticiens() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/opticiens'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => OpticienModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur de chargement des opticiens');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  static Future<bool> verifyOpticien(String opticienId, bool isVerified) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/opticiens/$opticienId/verify'),
        headers: _getHeaders(),
        body: json.encode({'isVerified': isVerified}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteOpticien(String opticienId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/opticiens/$opticienId'),
        headers: _getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ============ GESTION DES ASSURANCES ============

  static Future<List<InsuranceModel>> getInsurances() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/insurances'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => InsuranceModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur de chargement des assurances');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  static Future<bool> createInsurance(InsuranceModel insurance) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/insurances'),
        headers: _getHeaders(),
        body: json.encode(insurance.toJson()),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateInsurance(InsuranceModel insurance) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/insurances/${insurance.id}'),
        headers: _getHeaders(),
        body: json.encode(insurance.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteInsurance(String insuranceId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/insurances/$insuranceId'),
        headers: _getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ============ STATISTIQUES ============

  static Future<StatisticsModel> getStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/statistics'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return StatisticsModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur de chargement des statistiques');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // ============ GESTION DES LUNETTES ============

  static Future<List<GlassesModel>> getGlasses({String? category}) async {
    try {
      String url = '$baseUrl/glasses';
      if (category != null) {
        url += '?category=$category';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => GlassesModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur de chargement des lunettes');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}