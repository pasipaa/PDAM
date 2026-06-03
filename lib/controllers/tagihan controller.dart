import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ukl_mobile_uiux/services/tagihan_services.dart';
class TagihanController with ChangeNotifier {
  final TagihanService _tagihanService = TagihanService();

  List<dynamic> _bills = [];
  bool _isLoading = false;
  final List<int> _processingBillIds = [];

  List<dynamic> get bills => _bills;
  bool get isLoading => _isLoading;
  List<int> get processingBillIds => _processingBillIds;

  Future<String> _getValidToken(String tokenFallback) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? tokenFallback;
  }

  Future<void> getBills(String token) async {
    _isLoading = true;
    _bills = []; 
    notifyListeners(); 

    try {
      final String tokenLokal = await _getValidToken(token);

      debugPrint("=== GET BILLS API VIA SERVICE ===");
      final response = await _tagihanService.fetchBills(tokenLokal);

      print("=== DEBUG API TAGIHAN ===");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        final List<dynamic> rawList = data['data'] is List ? data['data'] : data; 

        _bills = rawList;
        print("Berhasil memuat ${_bills.length} data tagihan.");
      } else {
        final resBody = json.decode(response.body);
        throw resBody['message'] ?? "Gagal ambil data tagihan (Status ${response.statusCode})";
      }
    } catch (e, stacktrace) {
      print("Terjadi ERROR pada Controller (getBills): $e");
      print("Stacktrace: $stacktrace");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  Future<bool> createBill(Map<String, dynamic> bodyData, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final String tokenLokal = await _getValidToken(token);

      debugPrint("=== CREATE BILL API VIA SERVICE ===");
      final response = await _tagihanService.createBill(bodyData, tokenLokal);

      print("=== DEBUG SIMPAN DATA ===");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Data antrean tagihan baru berhasil ditambahkan!");
        return true;
      } else {
        print("Gagal membuat tagihan baru. Status: ${response.statusCode}");
        
        final resBody = json.decode(response.body);
        final String errorMsg = resBody['message'] ?? "Gagal membuat tagihan baru.";
        
        throw errorMsg;
      }
    } catch (e) {
      print("Terjadi Exception pada createBill: $e");
      rethrow; 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBill(int billId, Map<String, dynamic> updateData, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final String tokenLokal = await _getValidToken(token);

      debugPrint("=== UPDATE BILL API VIA SERVICE ===");
      final response = await _tagihanService.updateBill(billId, updateData, tokenLokal);

      print("=== DEBUG UPDATE DATA ===");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 201) {
        print("Data tagihan ID $billId berhasil diperbarui!");
        return true;
      } else {
        print("Gagal memperbarui data tagihan. Status: ${response.statusCode}");
        
        final resBody = json.decode(response.body);
        final String errorMsg = resBody['message'] ?? "Gagal memperbarui data tagihan.";
        throw errorMsg;
      }
    } catch (e) {
      print("Terjadi Exception pada updateBill: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBill(int billId, String token) async {
    try {
      final String tokenLokal = await _getValidToken(token);

      debugPrint("=== DELETE BILL API VIA SERVICE ===");
      final response = await _tagihanService.deleteBill(billId, tokenLokal);

      print("=== DEBUG HAPUS DATA ===");
      print("Status Code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        _bills.removeWhere((bill) => bill['id'] == billId);
        notifyListeners();
        return true;
      } else {
        final resBody = json.decode(response.body);
        throw resBody['message'] ?? "Gagal menghapus data.";
      }
    } catch (e) {
      print("Error Hapus Data: $e");
      rethrow;
    }
  }

  Future<bool> verifyBill(Map<String, dynamic> bill, String token) async {
    if (bill['payments'] == null) {
      print("Gagal verifikasi: Pelanggan belum mengunggah bukti pembayaran.");
      throw "Pelanggan belum mengunggah bukti pembayaran.";
    }

    final int paymentId = int.tryParse(bill['payments']['id'].toString()) ?? 0;
    final int billId = int.tryParse(bill['id'].toString()) ?? 0;

    if (paymentId == 0) {
      print("Gagal: ID Pembayaran tidak valid.");
      throw "ID Pembayaran tidak valid.";
    }

    _processingBillIds.add(billId);
    notifyListeners();

    try {
      final String tokenLokal = await _getValidToken(token);

      debugPrint("=== VERIFY PAYMENT API VIA SERVICE ===");
      final response = await _tagihanService.verifyPayment(paymentId, tokenLokal);

      print("=== DEBUG VERIFY API ===");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      _processingBillIds.remove(billId);
      notifyListeners();

      if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 201) {
        print("Verifikasi pembayaran ID $paymentId berhasil!");
        await getBills(tokenLokal);
        return true;
      } else {
        final resBody = json.decode(response.body);
        throw resBody['message'] ?? "Gagal memverifikasi pembayaran.";
      }
    } catch (e) {
      _processingBillIds.remove(billId);
      notifyListeners();
      print("Exception Verify: $e");
      rethrow;
    }
  }
}