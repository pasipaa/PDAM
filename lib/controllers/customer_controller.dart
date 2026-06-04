import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ukl_mobile_uiux/models/customer_models.dart';
import 'package:ukl_mobile_uiux/services/api_services.dart';
import 'package:ukl_mobile_uiux/services/url.dart' as url;

class CustomerAdminController extends ChangeNotifier {
  List<CustomerModel> _customers = [];
  List<CustomerModel> get customers => _customers;

  List<ServiceModel> _services = [];
  List<ServiceModel> get services => _services;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingServices = false;
  bool get isLoadingServices => _isLoadingServices;

  // ─── GET ALL CUSTOMERS ───────────────────────────────────────────────────────
  Future<void> getCustomers(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse("${url.BaseUrl}/customers"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "app-key": url.AppKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        _customers = data.map((item) => CustomerModel.fromJson(item)).toList();
      } else {
        debugPrint("[getCustomers] Status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("[getCustomers] Error: $e");
    } finally {
      _isLoading = false;
      _notifySafely();
    }
  }

  // ─── GET SERVICES ────────────────────────────────────────────────────────────
  Future<void> getServices(String token) async {
    _isLoadingServices = true;
    notifyListeners();
    try {
      final response = await ApiService.getData("/services", token);
      final List<dynamic> rawData = response['data'] ?? [];
      _services = rawData.map((item) => ServiceModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint("[getServices] Error: $e");
      _services = [];
    } finally {
      _isLoadingServices = false;
      _notifySafely();
    }
  }

  // ─── DELETE CUSTOMER ─────────────────────────────────────────────────────────
  // Langsung hit HTTP delete agar bisa baca status code & pesan error dari server.
  // Return: {"success": true} atau {"success": false, "message": "..."}
  Future<Map<String, dynamic>> deleteCustomer(int id, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse("${url.BaseUrl}/customers/$id"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "app-key": url.AppKey,
        },
      );

      debugPrint("[deleteCustomer] DELETE -> /customers/$id | Status: ${response.statusCode}");
      debugPrint("[deleteCustomer] Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        _customers.removeWhere((c) => c.id == id);
        return {"success": true};
      }

      // Baca pesan error dari server
      String errorMsg = "Gagal menghapus customer.";
      try {
        final body = jsonDecode(response.body);
        final raw = (body["message"] ?? "").toString();

        // Status 500 dari Prisma foreign key constraint
        // → customer masih punya tagihan/pembayaran
        if (response.statusCode == 500 ||
            raw.toLowerCase().contains("foreign key") ||
            raw.toLowerCase().contains("constraint")) {
          errorMsg =
              "Customer tidak dapat dihapus karena masih memiliki data tagihan atau pembayaran aktif. Hapus tagihan terlebih dahulu.";
        } else if (raw.isNotEmpty) {
          errorMsg = raw;
        }
      } catch (_) {
        errorMsg = "Gagal menghapus customer (${response.statusCode}).";
      }

      return {"success": false, "message": errorMsg};
    } catch (e) {
      debugPrint("[deleteCustomer] Error: $e");
      return {"success": false, "message": "Terjadi kesalahan sistem."};
    } finally {
      _isLoading = false;
      _notifySafely();
    }
  }

  // ─── SAVE (REGISTER) CUSTOMER ────────────────────────────────────────────────
  // Payload sesuai Postman: username, password, name, customer_number, phone, address, service_id
  // Setelah tersimpan, customer langsung bisa login dengan username & password ini.
  Future<Map<String, dynamic>> saveCustomer({
    required String token,
    required String username,
    required String password,
    required String name,
    required String customerNumber,
    required String phone,
    required String address,
    required int serviceId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> bodyPayload = {
        "username": username.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ''),
        "password": password.trim(),
        "name": name.trim(),
        "customer_number": customerNumber.trim(),
        "phone": phone.trim(),
        "address": address.trim(),
        "service_id": serviceId,
      };

      debugPrint("[saveCustomer] POST -> /customers | payload: $bodyPayload");

      final response = await ApiService.postData("/customers", bodyPayload, token);

      debugPrint("[saveCustomer] Response: $response");

      if (response.containsKey("error") ||
          response["success"] == false ||
          response["statusCode"] == 400 ||
          response["statusCode"] == 409) {
        return {
          "success": false,
          "message": response["message"] ??
              "Gagal mendaftarkan customer. Username atau nomor pelanggan mungkin sudah terdaftar.",
        };
      }

      await getCustomers(token);

      return {
        "success": true,
        "message": "Customer berhasil didaftarkan dan dapat login.",
        "username": username,
      };
    } catch (e) {
      debugPrint("[saveCustomer] Error: $e");
      return {"success": false, "message": "Terjadi kesalahan sistem: $e"};
    } finally {
      _isLoading = false;
      _notifySafely();
    }
  }

  // ─── UPDATE CUSTOMER ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> updateCustomer({
    required int id,
    required String token,
    required String username,
    String? password,
    required String name,
    required String customerNumber,
    required String phone,
    required String address,
    required int serviceId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> bodyData = {
        "username": username.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ''),
        "name": name.trim(),
        "customer_number": customerNumber.trim(),
        "phone": phone.trim(),
        "address": address.trim(),
        "service_id": serviceId,
      };

      if (password != null && password.trim().isNotEmpty) {
        bodyData["password"] = password.trim();
      }

      debugPrint("[updateCustomer] PATCH -> /customers/$id | payload: $bodyData");

      final response = await ApiService.patchData("/customers/$id", bodyData, token);

      debugPrint("[updateCustomer] Response: $response");

      if (response.containsKey("error") ||
          response["success"] == false ||
          response["statusCode"] == 400 ||
          response["statusCode"] == 409) {
        return {
          "success": false,
          "message": response["message"] ??
              "Gagal memperbarui data customer. Username atau nomor pelanggan sudah digunakan.",
        };
      }

      await getCustomers(token);
      return {"success": true, "message": "Berhasil memperbarui data customer"};
    } catch (e) {
      debugPrint("[updateCustomer] Error: $e");
      return {"success": false, "message": "Terjadi kesalahan sistem: $e"};
    } finally {
      _isLoading = false;
      _notifySafely();
    }
  }

  // ─── HELPER ──────────────────────────────────────────────────────────────────
  void _notifySafely() {
    if (hasListeners) notifyListeners();
  }
}

// ─── SERVICE MODEL ────────────────────────────────────────────────────────────
class ServiceModel {
  final int id;
  final String name;

  ServiceModel({required this.id, required this.name});

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
    );
  }
}