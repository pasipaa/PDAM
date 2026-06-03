import 'package:flutter/material.dart'; // Ditambahkan agar fungsi debugPrint() bisa terbaca
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukl_mobile_uiux/services/url.dart' as url; // Import url.dart Anda

class CustomerApiService {
  final String baseUrl = url.BaseUrl;
  final String appKey = url.AppKey;

  Future<Map<String, String>> _getHeaders({required bool requireToken}) async {
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "app-key": appKey,
      "APP-KEY": appKey,
    };

    if (requireToken) {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token') ?? prefs.getString('token')?.trim();
      
      if (token != null) {
        if (token.startsWith('Bearer ')) {
          token = token.substring(7).trim();
        }
        if (token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
          headers['authorization'] = 'Bearer $token';
        }
      }

      debugPrint("=== GET LAYANAN API ===");
      debugPrint("URL: $baseUrl");
      debugPrint("Token: Bearer $token");
    }
    return headers;
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders(requireToken: true);
    return await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: headers,
    );
  }

  Future<http.StreamedResponse> postMultipart({
    required String endpoint,
    required Map<String, String> fields,
    required String fileKey,
    required String filePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token') ?? prefs.getString('token')?.trim();

    if (token != null && token.startsWith('Bearer ')) {
      token = token.substring(7).trim();
    }

    var request = http.MultipartRequest('POST', Uri.parse("$baseUrl$endpoint"));
    
    request.headers.addAll({
      'Accept': 'application/json',
      'APP-KEY': appKey,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    });

    request.fields.addAll(fields);

    request.files.add(await http.MultipartFile.fromPath(fileKey, filePath));

    return await request.send();
  }
}