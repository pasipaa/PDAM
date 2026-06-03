import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ukl_mobile_uiux/services/url.dart' as url;

class TagihanService {
  Map<String, String> _getHeaders(String token) => {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "app-key": url.AppKey,
        "APP-KEY": url.AppKey,
      };

  final Duration _timeoutDuration = const Duration(seconds: 15);

  Future<http.Response> _safeRequest(Future<http.Response> Function() requestCall) async {
    try {
      return await requestCall().timeout(_timeoutDuration);
    } on SocketException {
      return http.Response(
        json.encode({"message": "Koneksi internet terputus. Silakan periksa jaringan Anda."}),
        503,
        headers: {"content-type": "application/json"},
      );
    } on TimeoutException {
      return http.Response(
        json.encode({"message": "Waktu tunggu habis (Timeout). Server sedang sibuk."}),
        408, // Request Timeout
        headers: {"content-type": "application/json"},
      );
    } catch (e) {
      // Menangkap error tidak terduga lainnya
      return http.Response(
        json.encode({"message": "Terjadi kesalahan jaringan sistem: $e"}),
        500, // Internal Server Error
        headers: {"content-type": "application/json"},
      );
    }
  }
  Future<http.Response> fetchBills(String token) async {
    final uri = Uri.parse("${url.BaseUrl}/bills");
    return await _safeRequest(() => http.get(uri, headers: _getHeaders(token)));
  }

  Future<http.Response> createBill(Map<String, dynamic> bodyData, String token) async {
    final uri = Uri.parse("${url.BaseUrl}/bills");
    return await _safeRequest(() => http.post(
          uri,
          headers: _getHeaders(token),
          body: json.encode(bodyData),
        ));
  }

  Future<http.Response> updateBill(int billId, Map<String, dynamic> updateData, String token) async {
    final uri = Uri.parse("${url.BaseUrl}/bills/$billId");
    return await _safeRequest(() => http.patch(
          uri,
          headers: _getHeaders(token),
          body: json.encode(updateData),
        ));
  }

  Future<http.Response> deleteBill(int billId, String token) async {
    final uri = Uri.parse("${url.BaseUrl}/bills/$billId");
    return await _safeRequest(() => http.delete(uri, headers: _getHeaders(token)));
  }

  Future<http.Response> verifyPayment(int paymentId, String token) async {
    final uri = Uri.parse("${url.BaseUrl}/payments/$paymentId");
    return await _safeRequest(() => http.patch(uri, headers: _getHeaders(token)));
  }
}