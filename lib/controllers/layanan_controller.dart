import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukl_mobile_uiux/services/url.dart' as url;

class LayananController with ChangeNotifier {
  List<dynamic> _layanan = [];
  bool _isLoading = false;

  List<dynamic> get layanan => _layanan;
  bool get isLoading => _isLoading;

  Future<void> getLayanan(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final String tokenLokal = prefs.getString('auth_token') ?? token;
      final response = await http.get(
        Uri.parse("${url.BaseUrl}/services"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $tokenLokal",
          "app-key": url.AppKey,
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _layanan = data['data'] ?? [];
      }
    } catch (e) {
      debugPrint("Error getLayanan: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createLayanan({
    required String name,
    required int minUsage,
    required int maxUsage,
    required int price,
    required String token,
    File? image,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String tokenLokal = prefs.getString('auth_token') ?? token;

      final response = await http.post(
        Uri.parse("${url.BaseUrl}/services"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $tokenLokal",
          "app-key": url.AppKey,
        },
        body: jsonEncode({
          "name": name,
          "min_usage": minUsage,
          "max_usage": maxUsage,
          "price": price,
        }),
      );

      debugPrint("Status Code Create: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        await getLayanan(tokenLokal);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error createLayanan: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateLayanan({
    required int id,
    required String name,
    required int minUsage,
    required int maxUsage,
    required int price,
    String? token,
    File? image,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final String tokenLokal = prefs.getString('auth_token') ?? token ?? '';

      final response = await http.patch(
        Uri.parse("${url.BaseUrl}/services/$id"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $tokenLokal",
          "app-key": url.AppKey,
        },
        body: jsonEncode({
          "name": name,
          "min_usage": minUsage,
          "max_usage": maxUsage,
          "price": price,
        }),
      );

      if (response.statusCode == 200) {
        await getLayanan(tokenLokal);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteLayanan(int id, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final String tokenLokal = prefs.getString('auth_token') ?? token;
      final response = await http.delete(
        Uri.parse("${url.BaseUrl}/services/$id"),
        headers: {
          "Authorization": "Bearer $tokenLokal",
          "app-key": url.AppKey,
        },
      );
      if (response.statusCode == 200) {
        await getLayanan(tokenLokal);
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}