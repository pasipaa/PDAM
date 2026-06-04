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

  /// 1. GET ALL LAYANAN
  Future<void> getLayanan(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String tokenLokal = prefs.getString('auth_token') ?? token;

      final uri = Uri.parse("${url.BaseUrl}/services");

      debugPrint("=== GET LAYANAN API ===");
      debugPrint("URL: $uri");
      debugPrint("Token: Bearer $tokenLokal");

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $tokenLokal",
          "app-key": url.AppKey,
          "APP-KEY": url.AppKey,
        },
      );

      debugPrint("Status Code Get: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        if (responseData.containsKey('data')) {
          _layanan = responseData['data'] ?? [];
        } else {
          _layanan = responseData as List<dynamic>;
        }
        
        debugPrint("Berhasil memuat ${_layanan.length} data layanan.");
      } else {
        debugPrint("Gagal mengambil data layanan: ${response.body}");
      }
    } catch (e) {
      debugPrint("Terjadi error pada LayananController (getLayanan): $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 2. CREATE LAYANAN (MENGGUNAKAN JSON ENCODE - REKOMENDASI FIX 400 BAD REQUEST)
  Future<bool> createLayanan({
    required String name,
    required int minUsage,
    required int maxUsage,
    required int price,
    required String token,
    File? image, // Tetap sediakan parameter agar tidak error di view kamu
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String tokenLokal = prefs.getString('auth_token') ?? token;

      final uri = Uri.parse("${url.BaseUrl}/services");
      
      debugPrint("=== PROSES CREATE LAYANAN (JSON ENCODE) ===");
      debugPrint("URL: $uri");

      // Mengirimkan JSON murni agar tipe data int (number) dibaca sempurna oleh backend
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $tokenLokal",
          "app-key": url.AppKey,
          "APP-KEY": url.AppKey,
        },
        body: jsonEncode({
          "name": name.trim(),
          "min_usage": minUsage, // Lolos sebagai integer murni
          "max_usage": maxUsage, // Lolos sebagai integer murni
          "price": price,         // Lolos sebagai integer murni
        }),
      );

      debugPrint("Status Code Create: ${response.statusCode}");
      debugPrint("Response Body Create: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh list setelah data berhasil disimpan
        await getLayanan(tokenLokal);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error create layanan: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 3. UPDATE LAYANAN (PATCH)
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

      if (tokenLokal.isEmpty) {
        debugPrint("=== ERROR UPDATE LAYANAN ===");
        debugPrint("Gagal Update: Token Autentikasi Kosong!");
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final uri = Uri.parse("${url.BaseUrl}/services/$id");
      
      debugPrint("=== PROSES UPDATE LAYANAN (PATCH) ===");
      debugPrint("URL: $uri");

      final response = await http.patch(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $tokenLokal",
          "app-key": url.AppKey,
          "APP-KEY": url.AppKey,
        },
        body: jsonEncode({
          "name": name.trim(),
          "min_usage": minUsage,
          "max_usage": maxUsage,
          "price": price,
        }),
      );

      debugPrint("Status Code Patch: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        await getLayanan(tokenLokal);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error update layanan: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 4. DELETE LAYANAN
  Future<bool> deleteLayanan(int id, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String tokenLokal = prefs.getString('auth_token') ?? token;

      final uri = Uri.parse("${url.BaseUrl}/services/$id");

      debugPrint("=== DELETE LAYANAN ===");
      debugPrint("URL: $uri");

      final response = await http.delete(
        uri,
        headers: {
          "Authorization": "Bearer $tokenLokal",
          "Accept": "application/json",
          "app-key": url.AppKey,
          "APP-KEY": url.AppKey,
        },
      );

      debugPrint("Status Code Delete: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        await getLayanan(tokenLokal);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error delete layanan: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 5. CLEAR DATA (LOGOUT HANDLER)
  void clearData() {
    _layanan = [];
    _isLoading = false;
    notifyListeners();
  }
}