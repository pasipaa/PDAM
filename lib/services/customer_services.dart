import 'package:ukl_mobile_uiux/models/customer_models.dart';
import 'package:ukl_mobile_uiux/services/api_services.dart';

class CustomerService {
  Future<List<CustomerModel>> getCustomers(String token) async {
    final response = await ApiService.getData("/customers", token);

    if (response.containsKey("error") || response["success"] == false) {
      throw Exception(response["message"] ?? "Gagal mengambil data");
    }

    final List<dynamic> data = response['data'] ?? []; 
    return data.map((item) => CustomerModel.fromJson(item)).toList();
  }

  Future<bool> deleteCustomer(int id, String token) async {
    final response = await ApiService.deleteData("/customers/$id", token);

    if (response.containsKey("error") || response["success"] == false) {
      return false;
    }
    
    return true; 
  }

  Future<bool> updateCustomer(int id, Map<String, dynamic> body, String token) async {
    final response = await ApiService.patchData("/customers/$id", body, token);

    if (response.containsKey("error") || response["success"] == false) {
      print("[UPDATE FAILED] Message: ${response["message"]}"); 
      return false;
    }
    
    print("[UPDATE SUCCESS] Berhasil memperbarui data customer ID: $id");
    return true; 
  }
}