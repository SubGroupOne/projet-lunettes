import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class NotificationService {
  final String baseUrl = 'http://localhost:3000';

  /// Récupère les notifications d'un utilisateur
  Future<List<Map<String, dynamic>>> getNotifications(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List notifications = json.decode(response.body);
        return notifications.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erreur lors de la récupération des notifications');
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  /// Marque une notification comme lue
  Future<bool> markAsRead(String accessToken, int notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  /// Simule une notification locale (pour démo)
  static List<Map<String, dynamic>> getMockNotifications() {
    return [
      {
        'id': 1,
        'type': 'order',
        'title': 'Commande confirmée',
        'message': 'Votre commande #12345 a été confirmée par l\'opticien',
        'is_read': false,
        'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 2,
        'type': 'order',
        'title': 'Commande en préparation',
        'message': 'Votre commande #12345 est en cours de préparation',
        'is_read': false,
        'created_at': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      },
      {
        'id': 3,
        'type': 'system',
        'title': 'Bienvenue !',
        'message': 'Merci d\'utiliser notre application de vente de lunettes',
        'is_read': true,
        'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
    ];
  }
}
