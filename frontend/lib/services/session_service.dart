import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService extends ChangeNotifier {
  static const String _tokenKey = 'accessToken';
  static const String _guestCartKey = 'guest_cart';
  static const String _userCartKey = 'user_cart_';
  static const String _guestFavsKey = 'guest_favorites';

  bool _isLoggedIn = false;
  String? _userName;
  String? _userEmail;
  String? _token;
  int? _userId;

  bool get isLoggedIn => _isLoggedIn;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get token => _token;

  SessionService() {
    checkSession();
  }

  /// Vérifie l'état de la session au démarrage
  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    
    if (token != null && token.isNotEmpty) {
      _isLoggedIn = true;
      _token = token;
      _userName = prefs.getString('userName');
      _userEmail = prefs.getString('userEmail');
      _userId = prefs.getInt('userId');
    } else {
      _isLoggedIn = false;
      _token = null;
    }
    notifyListeners();
  }

  /// Sauvegarde le panier temporaire (Guest)
  Future<void> saveGuestCart(List<Map<String, dynamic>> cartItems) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_guestCartKey, json.encode(cartItems));
  }

  /// Récupère le panier temporaire (Guest)
  Future<List<Map<String, dynamic>>> getGuestCart() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_guestCartKey);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(json.decode(data));
  }

  /// Fusionne les données Guest vers le compte User après login
  Future<void> mergeGuestData(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Fusion Cart
    final guestCart = await getGuestCart();
    if (guestCart.isNotEmpty) {
      final userCartKey = '$_userCartKey$userId';
      final existingUserCartData = prefs.getString(userCartKey);
      List<Map<String, dynamic>> userCart = existingUserCartData != null 
          ? List<Map<String, dynamic>>.from(json.decode(existingUserCartData))
          : [];

      // Merger sans doublons par ID
      for (var guestItem in guestCart) {
        if (!userCart.any((item) => item['id'] == guestItem['id'])) {
          userCart.add(guestItem);
        }
      }

      await prefs.setString(userCartKey, json.encode(userCart));
      await prefs.remove(_guestCartKey); // Nettoyer guest cart
      debugPrint('🛒 Panier fusionné pour l\'utilisateur $userId');
    }

    // 2. Fusion Favoris
    final guestFavs = prefs.getStringList(_guestFavsKey) ?? [];
    if (guestFavs.isNotEmpty) {
      final userFavsKey = 'user_favorites_$userId';
      final userFavs = prefs.getStringList(userFavsKey) ?? [];
      
      final mergedFavs = {...guestFavs, ...userFavs}.toList();
      await prefs.setStringList(userFavsKey, mergedFavs);
      await prefs.remove(_guestFavsKey);
      debugPrint('❤️ Favoris fusionnés pour l\'utilisateur $userId');
    }

    await checkSession();
  }

  /// Déconnexion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isLoggedIn = false;
    _userName = null;
    _userEmail = null;
    _userId = null;
    notifyListeners();
  }
}
