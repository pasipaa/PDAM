import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ukl_mobile_uiux/models/profile_models.dart';
import 'package:ukl_mobile_uiux/services/url.dart' as uri;

class ProfileService {
  final String baseUrl = uri.BaseUrl; 
  final String appKey = uri.AppKey; 

  Future<ProfileModel?> fetchProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/admins/me"), 
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token", 
          "app-key": appKey,               
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data') && responseData['data'] != null) {
          return ProfileModel.fromJson(responseData["data"]);
        } else {
          return ProfileModel.fromJson(responseData);
        }
      } else {
        throw Exception("Gagal memuat profil. Status: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ProfileModel?> updateProfile({
    required String token,
    required String id, 
    required String name,
    required String phone,
    String? password,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/admins/$id"); 

      final Map<String, dynamic> bodyData = {
        "name": name,
        "phone": phone,
      };

      if (password != null && password.isNotEmpty) {
        bodyData["password"] = password;
      }

      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "app-key": appKey, 
        },
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body); 
        
        if (responseData.containsKey('data') && responseData['data'] != null) {
          return ProfileModel.fromJson(responseData["data"]);
        } else {
          return ProfileModel.fromJson(responseData);
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}