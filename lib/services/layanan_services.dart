import 'package:ukl_mobile_uiux/services/api_services.dart';

class LayananService {
  Future<List<dynamic>> getLayanan(String token) async {
    try {
      final response = await ApiService.getData("/services", token);

      if (response.containsKey('error') && response['error'] == true) {
        throw Exception(response['message']);
      }

      if (response.containsKey('data') && response['data'] != null) {
        return response['data'] as List<dynamic>;
      }
      
      return [];
    } catch (e) {
      print("Error di LayananService (getLayanan): $e");
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> addLayanan(Map<String, dynamic> body, String token) async {
    try {
      final response = await ApiService.postData("/services", body, token);

      if (response.containsKey('error') && response['error'] == true) {
        throw Exception(response['message']);
      }

      return response;
    } catch (e) {
      print("Error di LayananService (addLayanan): $e");
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> updateLayanan(int id, Map<String, dynamic> body, String token) async {
    try {
      final response = await ApiService.putData("/services/$id", body, token);

      if (response.containsKey('error') && response['error'] == true) {
        throw Exception(response['message']);
      }

      return response;
    } catch (e) {
      print("Error di LayananService (updateLayanan): $e");
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> deleteLayanan(int id, String token) async {
    try {
      final response = await ApiService.deleteData("/services/$id", token);

      if (response.containsKey('error') && response['error'] == true) {
        throw Exception(response['message']);
      }

      return response;
    } catch (e) {
      print("Error di LayananService (deleteLayanan): $e");
      rethrow;
    }
  }
}