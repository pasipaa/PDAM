import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ukl_mobile_uiux/models/customer_models.dart';
import 'package:ukl_mobile_uiux/services/customer_services.dart';
import 'package:ukl_mobile_uiux/services/api_services.dart';
import 'package:ukl_mobile_uiux/services/url.dart' as url;

class CustomerAdminController extends ChangeNotifier {
  final CustomerService _customerService = CustomerService();

  List<CustomerModel> _customers = [];
  List<CustomerModel> get customers => _customers;

  List<ServiceModel> _services = [];
  List<ServiceModel> get services => _services;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingServices = false;
  bool get isLoadingServices => _isLoadingServices;

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
      }
    } catch (e) {
      debugPrint("Error fetch: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getServices(String token) async {
    _isLoadingServices = true;
    notifyListeners();
    try {
      final response = await ApiService.getData("/services", token);
      final List<dynamic> rawData = response['data'] ?? [];
      _services = rawData.map((item) => ServiceModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint("Error Fetching Services: $e");
      _services = [];
    } finally {
      _isLoadingServices = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCustomer(int id, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _customerService.deleteCustomer(id, token);
      if (success) {
        _customers.removeWhere((customer) => customer.id == id);
      }
      return success;
    } catch (e) {
      debugPrint("Error Deleting Customer: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
        "username": username.trim(),
        "password": password.trim(),
        "name": name.trim(),
        "customer_number": customerNumber.trim(),
        "phone": phone.trim(),
        "address": address.trim(),
        "service_id": serviceId,
      };

      final response = await ApiService.postData("/customers", bodyPayload, token);

      debugPrint("[API REQUEST] POST -> /customers");
      debugPrint("[SAVE CUSTOMER RESPONSE] : $response");

      if (response.containsKey("error") || response["success"] == false || response["statusCode"] == 400) {
        return {
          "success": false,
          "message": response["message"] ?? "Gagal menambahkan customer. Periksa kecocokan data field.",
        };
      }

      await getCustomers(token);
      return {"success": true, "message": "Berhasil menambahkan customer"};
    } catch (e) {
      debugPrint("Error Save Customer: $e");
      return {"success": false, "message": "Terjadi kesalahan sistem: $e"};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
        "username": username.trim(),
        "name": name.trim(),
        "customer_number": customerNumber.trim(),
        "phone": phone.trim(),
        "address": address.trim(),
        "service_id": serviceId,
      };

      if (password != null && password.isNotEmpty) {
        bodyData["password"] = password.trim();
      }

      final response = await ApiService.patchData("/customers/$id", bodyData, token);

      debugPrint("[API REQUEST] PATCH -> /customers/$id");
      debugPrint("[UPDATE CUSTOMER RESPONSE] : $response");

      if (response.containsKey("error") || response["success"] == false || response["statusCode"] == 400) {
        return {
          "success": false,
          "message": response["message"] ?? "Gagal memperbarui data customer",
        };
      }

      await getCustomers(token);
      return {"success": true, "message": "Berhasil memperbarui data customer"};
    } catch (e) {
      debugPrint("Error Update Customer: $e");
      return {"success": false, "message": "Terjadi kesalahan sistem: $e"};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

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