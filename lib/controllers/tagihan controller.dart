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
      final response = await _tagihanService.fetchBills(tokenLokal);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> rawList =
            data['data'] is List ? data['data'] : data;
        _bills = rawList;
      } else {
        final resBody = json.decode(response.body);
        throw resBody['message'] ??
            "Gagal ambil data tagihan (Status ${response.statusCode})";
      }
    } catch (e, stacktrace) {
      debugPrint("ERROR getBills: $e");
      debugPrint("Stacktrace: $stacktrace");
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
      final response = await _tagihanService.createBill(bodyData, tokenLokal);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final resBody = json.decode(response.body);
        throw resBody['message'] ?? "Gagal membuat tagihan baru.";
      }
    } catch (e) {
      debugPrint("ERROR createBill: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBill(
      int billId, Map<String, dynamic> updateData, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final String tokenLokal = await _getValidToken(token);
      final response =
          await _tagihanService.updateBill(billId, updateData, tokenLokal);

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        return true;
      } else {
        final resBody = json.decode(response.body);
        throw resBody['message'] ?? "Gagal memperbarui data tagihan.";
      }
    } catch (e) {
      debugPrint("ERROR updateBill: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBill(int billId, String token) async {
    try {
      final String tokenLokal = await _getValidToken(token);
      final response = await _tagihanService.deleteBill(billId, tokenLokal);

      if (response.statusCode == 200 || response.statusCode == 204) {
        _bills.removeWhere((bill) => bill['id'] == billId);
        notifyListeners();
        return true;
      } else {
        final resBody = json.decode(response.body);
        throw resBody['message'] ?? "Gagal menghapus data.";
      }
    } catch (e) {
      debugPrint("ERROR deleteBill: $e");
      rethrow;
    }
  }

  // Helper: ambil paymentId dari object bill
  int _extractPaymentId(Map<String, dynamic> bill) {
    final payments = bill['payments'];
    int paymentId = 0;

    if (payments is Map<String, dynamic>) {
      paymentId = int.tryParse(payments['id'].toString()) ?? 0;
    }

    // Fallback: cek field payment_id langsung di bill
    if (paymentId == 0 && bill['payment_id'] != null) {
      paymentId = int.tryParse(bill['payment_id'].toString()) ?? 0;
    }

    return paymentId;
  }

  Future<bool> verifyBill(Map<String, dynamic> bill, String token) async {
    final int billId = int.tryParse(bill['id'].toString()) ?? 0;
    final int paymentId = _extractPaymentId(bill);

    if (paymentId == 0) {
      throw "Pelanggan belum mengunggah bukti pembayaran.";
    }

    _processingBillIds.add(billId);
    notifyListeners();

    try {
      final String tokenLokal = await _getValidToken(token);
      final response =
          await _tagihanService.verifyPayment(paymentId, tokenLokal);

      debugPrint(
          "VERIFY status: ${response.statusCode} | body: ${response.body}");

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        await getBills(tokenLokal);
        return true;
      } else {
        final resBody = json.decode(response.body);
        throw resBody['message'] ?? "Gagal memverifikasi pembayaran.";
      }
    } catch (e) {
      debugPrint("ERROR verifyBill: $e");
      rethrow;
    } finally {
      _processingBillIds.remove(billId);
      notifyListeners();
    }
  }

  // ADDED: Tolak pembayaran — DELETE /payments/:paymentId
  Future<bool> rejectBill(Map<String, dynamic> bill, String token) async {
    final int billId = int.tryParse(bill['id'].toString()) ?? 0;
    final int paymentId = _extractPaymentId(bill);

    if (paymentId == 0) {
      throw "Pelanggan belum mengunggah bukti pembayaran.";
    }

    _processingBillIds.add(billId);
    notifyListeners();

    try {
      final String tokenLokal = await _getValidToken(token);
      final response =
          await _tagihanService.rejectPayment(paymentId, tokenLokal);

      debugPrint(
          "REJECT status: ${response.statusCode} | body: ${response.body}");

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        await getBills(tokenLokal);
        return true;
      } else {
        final resBody = json.decode(response.body);
        throw resBody['message'] ?? "Gagal menolak pembayaran.";
      }
    } catch (e) {
      debugPrint("ERROR rejectBill: $e");
      rethrow;
    } finally {
      _processingBillIds.remove(billId);
      notifyListeners();
    }
  }
}