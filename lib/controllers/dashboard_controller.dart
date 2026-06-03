import 'package:flutter/material.dart';
import 'package:ukl_mobile_uiux/models/profile_models.dart';
import 'package:ukl_mobile_uiux/services/api_services.dart';

class DashboardController extends ChangeNotifier {
  int totalCustomer = 0;
  int totalLayanan = 0;
  int totalTagihan = 0;
  
  ProfileModel? adminProfile;

  Future<ProfileModel?> getMyProfile(String token) async {
    try {
      final response = await ApiService.getData("/admins/me", token);
      if (response['success'] == true && response['data'] != null) {
        adminProfile = ProfileModel.fromJson(response['data']);
        notifyListeners();
        return adminProfile;
      }
    } catch (e) {
      debugPrint("Error getMyProfile: $e");
    }
    return null;
  }

  Future<int> getTotalCustomers(String token) async {
    try {
      final response = await ApiService.getData("/customers?page=1&quantity=500", token);
      if (response['success'] == true && response['data'] != null) {
        final List dataList = response['data'];
        totalCustomer = dataList.length; // 🔹 Update variabelmu
        notifyListeners();
        return totalCustomer;
      }
    } catch (e) {
      debugPrint("Error getTotalCustomers: $e");
    }
    return 0;
  }

  Future<int> getUnverifiedPaymentsCount(String token) async {
    try {
      final response = await ApiService.getData("/payments", token);
      if (response['success'] == true && response['data'] != null) {
        final List dataList = response['data'];
        totalTagihan = dataList.where((payment) {
          final status = payment['status']?.toString().toLowerCase() ?? '';
          return status == 'pending' || status == 'menunggu';
        }).length;
        
        notifyListeners();
        return totalTagihan;
      }
    } catch (e) {
      debugPrint("Error getUnverifiedPaymentsCount: $e");
    }
    return 0;
  }

  Future<int> getActiveServicesCount(String token) async {
    try {
      final response = await ApiService.getData("/services", token);
      if (response['success'] == true && response['data'] != null) {
        final List dataList = response['data'];
        totalLayanan = dataList.length;
        notifyListeners();
        return totalLayanan;
      }
    } catch (e) {
      debugPrint("Error getActiveServicesCount: $e");
    }
    return 0;
  }
}