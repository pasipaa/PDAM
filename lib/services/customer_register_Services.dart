import 'package:ukl_mobile_uiux/models/customer_register_models.dart';
import 'package:ukl_mobile_uiux/services/api_services.dart'; // Import ApiService milikmu

class CustomerRegisterService {
  Future<bool> registerCustomer(CustomerRegisterModel data, String token) async {
    try {
      final response = await ApiService.postData("/admins", data.toJson(), token);

      if (response["error"] == null || response["error"] == false) {
        return true;
      }
      return false;
    } catch (e) {
      print("Error di CustomerRegisterService: $e");
      return false;
    }
  }
}