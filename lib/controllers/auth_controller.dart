import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukl_mobile_uiux/services/api_services.dart';

class AuthController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String?> login({
    required String username,
    required String password,
    required bool isAdmin, 
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String endpoint = "/auth";
      final response = await ApiService.postData(
        endpoint,
        {
          "username": username,
          "password": password,
        },
        "",
      );

      debugPrint("[API REQUEST] POST -> $endpoint");
      debugPrint("[AUTH RESPONSE] : $response");
      if ((response['success'] == true || response.containsKey('token') || response.containsKey('owner_token'))) {
        
        String? token = response["owner_token"] ?? response["token"] ?? response["data"]?["token"];

        if (token != null && token.isNotEmpty) {
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token.toString());
          await prefs.setBool('is_admin', isAdmin); 
          
          debugPrint("Token Berhasil Disimpan di Lokal: '$token'");
          return token.toString();
        }
      }
      
      if (response.containsKey('message')) {
        throw Exception(response['message']);
      }
      
      return null; 
      
    } catch (e) {
      debugPrint("Error di AuthController: $e");
      String errorMsg = e.toString().replaceAll("Exception: ", "");
      throw Exception(errorMsg); 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.remove('token');
      await prefs.remove('is_admin');
      await prefs.remove('remember_me');
      
      debugPrint("Sesi berhasil dihapus (Logout sukses).");
    } catch (e) {
      debugPrint("Gagal melakukan logout: $e");
    }
  }
}