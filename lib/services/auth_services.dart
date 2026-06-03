import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ukl_mobile_uiux/services/url.dart' as url;

class AdminService {
  static Future register({
    required String name,
    required String phone,
    required String password,
  }) async {
    final uri = Uri.parse("${url.BaseUrl}/admins");

    var response = await http.post(
      uri,

      body: {"name": name, "phone": phone, "password": password},
    );

    return jsonDecode(response.body);
  }

  static Future login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse("${url.BaseUrl}/auth");

    var response = await http.post(
      uri,

      body: {"username": username, "password": password},
    );

    return jsonDecode(response.body);
  }
}