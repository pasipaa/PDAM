import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ukl_mobile_uiux/services/url.dart';

class ApiService {
  static const String _appKey = "c37f844fd9ee042b180261eb49bf457d6e3a5184";

  static Future<Map<String, dynamic>> request(String method, String endpoint, String token, {dynamic body}) async {
    final String formattedEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final uri = Uri.parse("$BaseUrl$formattedEndpoint");
    
    print("[DEBUG] Token: '$token'");

    final headers = {
      "Authorization": "Bearer $token",
      "app-key": _appKey,
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    try {
      print("[API REQUEST] $method -> $uri");
      http.Response response;
      final String? encodedBody = body != null ? jsonEncode(body) : null;

      switch (method) {
        case "POST": response = await http.post(uri, headers: headers, body: encodedBody); break;
        case "PATCH": response = await http.patch(uri, headers: headers, body: encodedBody); break;
        case "PUT": response = await http.put(uri, headers: headers, body: encodedBody); break;
        case "DELETE": response = await http.delete(uri, headers: headers); break;
        default: response = await http.get(uri, headers: headers);
      }

      print("[API RESPONSE] Status: ${response.statusCode}");
      print("[BODY] ${response.body}");

      if (response.body.isEmpty) return {"success": true};
      
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (data is Map<String, dynamic>) {
          data['success'] = true;
          return data;
        }
        return {"success": true, "data": data};
      } else {
        return {
          "success": false,
          "error": true,
          "message": (data is Map && data.containsKey("message")) ? data["message"] : "Terjadi kesalahan server",
          "statusCode": response.statusCode
        };
      }
    } catch (e) {
      print("[API ERROR] $e");
      return {"success": false, "error": true, "message": "Koneksi gagal: $e"};
    }
  }

  static Future<Map<String, dynamic>> getData(String e, String t) => request("GET", e, t);
  static Future<Map<String, dynamic>> postData(String e, dynamic b, String t) => request("POST", e, t, body: b);
  static Future<Map<String, dynamic>> patchData(String e, dynamic b, String t) => request("PATCH", e, t, body: b);
  static Future<Map<String, dynamic>> putData(String e, dynamic b, String t) => request("PUT", e, t, body: b);
  static Future<Map<String, dynamic>> deleteData(String e, String t) => request("DELETE", e, t);
}