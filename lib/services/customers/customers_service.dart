import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukl_mobile_uiux/services/url.dart' as url;

class CustomerCustService {
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
    }
    return headers;
  }

  Future<http.Response> fetchCustomersFromApi(String token) async {
    final targetUrl = Uri.parse('$baseUrl/customers');
    
    String cleanToken = token.trim();
    if (cleanToken.startsWith('Bearer ')) {
      cleanToken = cleanToken.substring(7).trim();
    }

    return await http.get(
      targetUrl,
      headers: {
        "Accept": "application/json",
        "APP-KEY": appKey,
        "Authorization": "Bearer $cleanToken",
      },
    );
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders(requireToken: true);
    return await http.get(
      Uri.parse("$baseUrl$endpoint"), 
      headers: headers,
    );
  }

  Future<http.StreamedResponse> postMultipart(
      String endpoint, Map<String, String> fields, String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token') ?? prefs.getString('token')?.trim();

    if (token != null && token.startsWith('Bearer ')) {
      token = token.substring(7).trim();
    }

    var request = http.MultipartRequest('POST', Uri.parse("$baseUrl$endpoint"));
    
    request.headers.addAll({
      "Accept": "application/json",
      'APP-KEY': appKey,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    });

    request.fields.addAll(fields);
    
    request.files.add(await http.MultipartFile.fromPath('image', filePath));

    return await request.send();
  }
}