import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukl_mobile_uiux/controllers/customer_controller.dart';

class TambahCustomerView extends StatefulWidget {
  final String token;
  const TambahCustomerView({super.key, required this.token});

  @override
  State<TambahCustomerView> createState() => _TambahCustomerViewState();
}

class _TambahCustomerViewState extends State<TambahCustomerView> {
  final usernameC = TextEditingController();
  final passwordC = TextEditingController();
  final customerNumberC = TextEditingController();
  final nameC = TextEditingController();
  final phoneC = TextEditingController();
  final addressC = TextEditingController();

  int? selectedServiceId;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerAdminController>().getServices(widget.token);
    });
  }

  @override
  void dispose() {
    usernameC.dispose();
    passwordC.dispose();
    customerNumberC.dispose();
    nameC.dispose();
    phoneC.dispose();
    addressC.dispose();
    super.dispose();
  }

  Future<void> handleSaveCustomer() async {
    if (usernameC.text.trim().isEmpty || passwordC.text.trim().isEmpty || nameC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username, Password, dan Nama tidak boleh kosong"), backgroundColor: Colors.red),
      );
      return;
    }

    if (passwordC.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password harus minimal 8 karakter"), backgroundColor: Colors.red),
      );
      return;
    }

    if (selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih jenis layanan terlebih dahulu"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final controller = context.read<CustomerAdminController>();
      String cleanUsername = usernameC.text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');

      final result = await controller.saveCustomer(
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

      if (result["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil mendaftarkan customer baru!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Gagal menyimpan data"), backgroundColor: Colors.red),
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
        title: const Text("Tambah Customer", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField("Username (Otomatis huruf kecil tanpa spasi)", "Contoh : bidin123", usernameC),
            _buildInputField("Password", "Minimal 8 Karakter", passwordC, isPassword: true),
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
                onPressed: loading ? null : handleSaveCustomer,
                child: loading 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text("Simpan Customer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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