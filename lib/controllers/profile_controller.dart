import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukl_mobile_uiux/models/profile_models.dart';
import 'package:ukl_mobile_uiux/services/profile_services.dart'; 

class ProfileController extends ChangeNotifier {
  ProfileModel? profile;
  bool isLoading = false;
  String? errorMessage;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  Future<void> getProfile(String token) async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String tokenPalingFresh = prefs.getString('auth_token') ?? token;

      final result = await ProfileService().fetchProfile(tokenPalingFresh);
      if (result != null) {
        profile = result;
      } else {
        errorMessage = "Data profil kosong.";
      }
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception:", "").trim();
      debugPrint("Error di ProfileController (getProfile): $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAdminProfile({
    required String token,
    required String name,
    required String phone,
    String? password,
  }) async {
    if (isLoading) return false;
    if (profile == null) {
      errorMessage = "ID Admin tidak ditemukan. Gagal memperbarui data.";
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String tokenPalingFresh = prefs.getString('auth_token') ?? token;

      final String adminId = profile!.id.toString();
      final result = await ProfileService().updateProfile(
        token: tokenPalingFresh,
        id: adminId, 
        name: name,
        phone: phone,
        password: password,
      );

      if (result != null) {
        profile = result; 
        return true; 
      } else {
        errorMessage = "Gagal memperbarui data profil di server.";
        return false;
      }
      
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception:", "").trim();
      debugPrint("Error di ProfileController (updateProfile): $e");
      return false; 
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}