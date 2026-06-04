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
  final usernameC       = TextEditingController();
  final passwordC       = TextEditingController();
  final nameC           = TextEditingController();
  final customerNumberC = TextEditingController();
  final phoneC          = TextEditingController();
  final addressC        = TextEditingController();

  int?  selectedServiceId;
  bool  loading         = false;
  bool  obscurePassword = true;

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
    nameC.dispose();
    customerNumberC.dispose();
    phoneC.dispose();
    addressC.dispose();
    super.dispose();
  }

  Future<void> handleSaveCustomer() async {
    if (usernameC.text.trim().isEmpty ||
        passwordC.text.trim().isEmpty ||
        nameC.text.trim().isEmpty) {
      _showSnackBar("Username, Password, dan Nama tidak boleh kosong",
          isError: true);
      return;
    }

    if (passwordC.text.trim().length < 8) {
      _showSnackBar("Password harus minimal 8 karakter", isError: true);
      return;
    }

    if (selectedServiceId == null) {
      _showSnackBar("Pilih jenis layanan terlebih dahulu", isError: true);
      return;
    }

    setState(() => loading = true);

    try {
      final controller = context.read<CustomerAdminController>();

      final cleanUsername = usernameC.text
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), '');

      final result = await controller.saveCustomer(
        token:          widget.token,
        username:       cleanUsername,
        password:       passwordC.text.trim(),
        name:           nameC.text.trim(),
        customerNumber: customerNumberC.text.trim(),
        phone:          phoneC.text.trim(),
        address:        addressC.text.trim(),
        serviceId:      selectedServiceId!,
      );

      if (!mounted) return;

      if (result["success"] == true) {
        _showSnackBar("Customer berhasil didaftarkan!");
        Navigator.pop(context, true);
      } else {
        _showSnackBar(result["message"] ?? "Gagal menyimpan data",
            isError: true);
      }
    } catch (e) {
      _showSnackBar("Terjadi kesalahan sistem: ${e.toString()}", isError: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
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
        title: const Text(
          "Tambah Customer",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xffE6F1FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffB5D4F4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline_rounded,
                      color: Color(0xff185FA5), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Setelah disimpan, customer langsung terdaftar dan dapat login menggunakan username & password yang diisi di form ini.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xff185FA5),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _sectionTitle("Akun Login Customer"),
            _buildInputField("Username",
                "Contoh: bidin123 (huruf kecil, tanpa spasi)", usernameC),
            _buildPasswordField(),

            _sectionTitle("Data Pelanggan"),
            _buildInputField("Nama Lengkap", "Masukkan nama lengkap", nameC),
            _buildInputField(
                "NIK / No. Meter", "Nomor Induk Kependudukan atau No. Meter",
                customerNumberC,
                keyboardType: TextInputType.number),
            _buildInputField("No. Telepon", "Contoh: 081335810890", phoneC,
                keyboardType: TextInputType.phone),
            _buildInputField("Alamat", "Tuliskan alamat lengkap", addressC,
                maxLines: 3),

            _sectionTitle("Layanan"),
            const Text("Pilih paket layanan yang diambil customer",
                style: TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xffE6E6E6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: controller.isLoadingServices
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
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
                        onChanged: (val) =>
                            setState(() => selectedServiceId = val),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal",
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0066FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: loading ? null : handleSaveCustomer,
                child: loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text("Simpan & Daftarkan Customer",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xff0066FF),
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildInputField(
    String title,
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xffE6E6E6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Password",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
        const SizedBox(height: 8),
        TextField(
          controller: passwordC,
          obscureText: obscurePassword,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            hintText: "Minimal 8 karakter",
            filled: true,
            fillColor: const Color(0xffE6E6E6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => obscurePassword = !obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}