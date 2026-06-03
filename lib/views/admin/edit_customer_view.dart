import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukl_mobile_uiux/controllers/customer_controller.dart';

class EditCustomerView extends StatefulWidget {
  final String token;
  final dynamic customer;

  const EditCustomerView({
    super.key,
    required this.token,
    required this.customer,
  });

  @override
  State<EditCustomerView> createState() => _EditCustomerViewState();
}

class _EditCustomerViewState extends State<EditCustomerView> {
  late TextEditingController usernameC;
  late TextEditingController passwordC;
  late TextEditingController customerNumberC;
  late TextEditingController nameC;
  late TextEditingController phoneC;
  late TextEditingController addressC;

  int? selectedServiceId;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    final data = widget.customer;

    String safeGet(String key) {
      if (data == null) return '';
      if (data is Map) {
        if (data.containsKey(key) && data[key] != null) {
          return data[key].toString();
        }
        if (key == 'username' && data['user'] is Map) {
          return (data['user']['username'] ?? '').toString();
        }
        return '';
      }
      
      try {
        if (key == 'username') {
          return (data.username ?? data.user?.username ?? '').toString();
        }
        if (key == 'name') return (data.name ?? '').toString();
        if (key == 'customer_number' || key == 'customerNumber') {
          return (data.customerNumber ?? data.customer_number ?? '').toString();
        }
        if (key == 'phone') return (data.phone ?? '').toString();
        if (key == 'address') return (data.address ?? '').toString();
      } catch (_) {}
      return '';
    }

    if (data is Map) {
      if (data['service_id'] != null) {
        selectedServiceId = int.tryParse(data['service_id'].toString());
      } else if (data['service'] != null && data['service'] is Map) {
        selectedServiceId = int.tryParse(data['service']['id'].toString());
      }
    } else {
      try {
        selectedServiceId = int.tryParse(data.serviceId.toString()) ?? data.service?.id;
      } catch (_) {
        try {
          final jsonMap = data.toJson();
          if (jsonMap['service_id'] != null) {
            selectedServiceId = int.tryParse(jsonMap['service_id'].toString());
          } else if (jsonMap['service'] != null && jsonMap['service'] is Map) {
            selectedServiceId = int.tryParse(jsonMap['service']['id'].toString());
          }
        } catch (_) {}
      }
    }

    usernameC = TextEditingController(text: safeGet('username'));
    passwordC = TextEditingController(); 
    nameC = TextEditingController(text: safeGet('name'));

    String cNum = safeGet('customer_number');
    if (cNum.isEmpty) cNum = safeGet('customerNumber');
    customerNumberC = TextEditingController(text: cNum);

    phoneC = TextEditingController(text: safeGet('phone'));
    addressC = TextEditingController(text: safeGet('address'));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerAdminController>().getServices(widget.token);
    });
  }

  @override
  void dispose() {
    usernameC.dispose();
    passwordC.dispose();
    nameC.dispose();
    customerNumberC.dispose();
    phoneC.dispose();
    addressC.dispose();
    super.dispose();
  }

  Future<void> handleUpdateCustomer() async {
    if (usernameC.text.trim().isEmpty || nameC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username dan Nama tidak boleh kosong"), backgroundColor: Colors.red),
      );
      return;
    }

    if (passwordC.text.isNotEmpty && passwordC.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password baru harus minimal 8 karakter"), backgroundColor: Colors.red),
      );
      return;
    }

    if (selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih jenis layanan terlebih dahulu"), backgroundColor: Colors.amber),
      );
      return;
    }

    setState(() => loading = true);
    
    try {
      final controller = context.read<CustomerAdminController>();

      int customerId = 0;
      if (widget.customer is Map) {
        customerId = int.tryParse(widget.customer['id'].toString()) ?? 0;
      } else {
        try {
          customerId = widget.customer.id ?? 0;
        } catch (_) {}
      }

      String cleanUsername = usernameC.text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');

      final result = await controller.updateCustomer(
        id: customerId,
        token: widget.token,
        username: cleanUsername,
        password: passwordC.text, 
        name: nameC.text.trim(),
        customerNumber: customerNumberC.text.trim(),
        phone: phoneC.text.trim(),
        address: addressC.text.trim(),
        serviceId: selectedServiceId!,
      );

      if (!mounted) return;

      if (result["success"] == true || result["message"].toString().toLowerCase().contains("updated")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data customer berhasil diperbarui!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Gagal memperbarui data"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan sistem: ${e.toString()}"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CustomerAdminController>();

    return Scaffold(
      backgroundColor: const Color(0xffF2F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xffF2F8FC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Edit Customer", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField("Username (Digunakan untuk Login)", "Contoh : bidin123", usernameC),
            _buildInputField("Password Baru (Opsional)", "Kosongkan jika tidak ingin mengganti password", passwordC, isPassword: true),
            _buildInputField("Nama Lengkap", "Masukkan nama", nameC),
            _buildInputField("NIK / No. Meter", "Nomor Induk Kependudukan", customerNumberC, keyboardType: TextInputType.number),
            _buildInputField("No. Telepon", "Contoh: 0812345678", phoneC, keyboardType: TextInputType.phone),
            _buildInputField("Alamat", "Tuliskan Alamat Lengkap", addressC, maxLines: 3),
            
            const Text("Layanan", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
            const SizedBox(height: 8),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: const Color(0xffE6E6E6), borderRadius: BorderRadius.circular(14)),
              child: controller.isLoadingServices
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: selectedServiceId,
                        hint: const Text("Pilih Layanan"),
                        items: controller.services.map((e) {
                          return DropdownMenuItem<int>(
                            value: e.id,
                            child: Text(e.name),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => selectedServiceId = val),
                      ),
                    ),
            ),
            
            const SizedBox(height: 36),
            
            SizedBox(
              width: double.infinity, 
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity, 
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0066FF), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: loading ? null : handleUpdateCustomer,
                child: loading 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String title, String hint, TextEditingController controller, {bool isPassword = false, TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
        const SizedBox(height: 8),
        TextField(
          controller: controller, 
          obscureText: isPassword, 
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint, 
            filled: true, 
            fillColor: const Color(0xffE6E6E6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          )
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}