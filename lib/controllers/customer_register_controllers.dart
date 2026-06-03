import 'package:flutter/material.dart';
import 'package:ukl_mobile_uiux/models/customer_register_models.dart';
import 'package:ukl_mobile_uiux/services/customer_register_Services.dart';

class CustomerRegisterController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> tambahCustomer({
    required String username,
    required String password,
    required String name,
    required String phone,
    required String token,
  }) async {
    _isLoading = true;
    notifyListeners();

    final customerData = CustomerRegisterModel(
      username: username,
      password: password,
      name: name,
      phone: phone,
    );

    final success = await CustomerRegisterService().registerCustomer(customerData, token);

    _isLoading = false;
    notifyListeners();
    return success;
  }
}