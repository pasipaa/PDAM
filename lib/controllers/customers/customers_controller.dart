import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart'; 
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukl_mobile_uiux/models/customers/customer_profile_models.dart';
import 'package:ukl_mobile_uiux/models/customers/customer_tagihan_models.dart';
import 'package:ukl_mobile_uiux/services/url.dart' as url;

// 1. Tambahkan 'with ChangeNotifier' agar bisa terintegrasi dengan Provider
class CustomerController with ChangeNotifier {
  final String baseUrl = url.BaseUrl;
  final String appKey = url.AppKey;

  // 2. Deklarasikan variabel state internal yang sesungguhnya
  CustomerProfile? _profile;
  String? _errorMessage;
  bool _isLoading = false;
  List<CustomerBill> _bills = [];

  // 3. Buat Getter yang mengembalikan variabel internal (bukan null lagi!)
  CustomerProfile? get profile => _profile;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  List<CustomerBill> get bills => _bills;

  get customers => null;

  Future<String> _getToken(String tokenParam) async {
    if (tokenParam.isNotEmpty) return tokenParam;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  // 4. Update getMyProfile agar menyimpan data ke state dan memicu notifyListeners()
  Future<CustomerProfile?> getMyProfile(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Beritahu UI untuk menampilkan loading spinner

    try {
      final String activeToken = await _getToken(token);
      final uri = Uri.parse("$baseUrl/customers/me");

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $activeToken",
          "app-key": appKey, 
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['data'] != null) {
          _profile = CustomerProfile.fromJson(responseData['data']);
        } else {
          _profile = CustomerProfile.fromJson(responseData);
        }
        return _profile;
      } else {
        _errorMessage = "Gagal memuat profil (${response.statusCode})";
        debugPrint("Status: ${response.statusCode}, Body: ${response.body}");
        return null;
      }
    } catch (e) {
      _errorMessage = "Terjadi kesalahan jaringan.";
      debugPrint("Error di getMyProfile: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners(); // Matikan loading spinner di UI
    }
  }

  Future<List<CustomerBill>> getMyBills(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String activeToken = await _getToken(token);
      final uri = Uri.parse("$baseUrl/bills/me?page=1&quantity=100&search=");
      
      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $activeToken",
          "app-key": appKey,
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        List<dynamic> listData = [];
        
        if (responseData['data'] != null) {
          if (responseData['data'] is List) {
            listData = responseData['data'];
          } else if (responseData['data']['results'] != null) {
            listData = responseData['data']['results'];
          }
        } else if (responseData['results'] != null) {
          listData = responseData['results'];
        }

        _bills = listData.map((item) => CustomerBill.fromJson(item)).toList();
        return _bills;
      } else {
        _errorMessage = "Gagal mengambil data tagihan.";
        return [];
      }
    } catch (e) {
      _errorMessage = "Terjadi kesalahan saat memuat tagihan.";
      debugPrint("Error di getMyBills: $e");
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadPayment(String billId, String imagePath, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final String activeToken = await _getToken(token);
      final uri = Uri.parse("$baseUrl/payments");
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer $activeToken",
        "app-key": appKey,
      });
      request.fields['bill_id'] = billId;
      
      if (imagePath.isNotEmpty && await File(imagePath).exists()) {
        final String extension = imagePath.split('.').last.toLowerCase();
        String mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';
        String targetExtension = extension == 'png' ? 'png' : 'jpg';

        request.files.add(
          await http.MultipartFile.fromPath(
            'file', 
            imagePath,
            filename: 'bukti_transfer.$targetExtension', 
            contentType: MediaType.parse(mimeType),      
          ),
        );
      } else {
        _errorMessage = "File bukti transfer tidak ditemukan.";
        return false;
      }

      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['message'] ?? "Gagal mengunggah bukti pembayaran.";
        return false;
      }
    } catch (e) {
      _errorMessage = "Terjadi kesalahan sistem saat mengunggah.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 5. Implementasikan Logika API untuk fungsi updateProfile Customer
  Future<bool> updateProfile({
    required String token, 
    required String name, 
    required String phone, 
    required String address, 
    required String username,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String activeToken = await _getToken(token);
      final uri = Uri.parse("$baseUrl/customers/update-profile"); // Sesuaikan endpoint dengan dokumentasi API-mu

      final response = await http.put(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $activeToken",
          "app-key": appKey,
        },
        body: json.encode({
          "name": name,
          "username": username,
          "phone": phone,
          "address": address,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Perbarui data profile lokal dengan data respons terbaru dari backend
        if (responseData['data'] != null) {
          _profile = CustomerProfile.fromJson(responseData['data']);
        }
        return true;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _errorMessage = errorData['message'] ?? "Gagal memperbarui data profil.";
        return false;
      }
    } catch (e) {
      _errorMessage = "Koneksi terputus. Silakan coba lagi.";
      debugPrint("Error di updateProfile: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCustomers(String token) async {}
}