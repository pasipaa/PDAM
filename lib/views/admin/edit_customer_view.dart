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

    final data = widget.customer;

    String safeGet(String key) {
      if (data == null) return '';
      if (data is Map) {
        if (data.containsKey(key) && data[key] != null) return data[key].toString();
        if (key == 'username' && data['user'] is Map) return (data['user']['username'] ?? '').toString();
        return '';
      }
      try {
        if (key == 'username') return (data.username ?? data.user?.username ?? '').toString();
        if (key == 'name') return (data.name ?? '').toString();
        if (key == 'customer_number' || key == 'customerNumber') return (data.customerNumber ?? data.customer_number ?? '').toString();
        if (key == 'phone') return (data.phone ?? '').toString();
        if (key == 'address') return (data.address ?? '').toString();
      } catch (_) {}
      return '';
    }

    // Service ID
    if (data is Map) {
      if (data['service_id'] != null) {
        selectedServiceId = int.tryParse(data['service_id'].toString());
      } else if (data['service'] is Map) {
        selectedServiceId = int.tryParse(data['service']['id'].toString());
      }
    } else {
      try {
        selectedServiceId = int.tryParse(data.serviceId.toString());
      } catch (_) {
        try {
          final j = data.toJson();
          selectedServiceId = int.tryParse((j['service_id'] ?? j['service']?['id'] ?? '').toString());
        } catch (_) {}
      }
    }

    usernameC.text       = safeGet('username');
    nameC.text           = safeGet('name');
    customerNumberC.text = safeGet('customer_number').isNotEmpty ? safeGet('customer_number') : safeGet('customerNumber');
    phoneC.text          = safeGet('phone');
    addressC.text        = safeGet('address');
    // password dikosongkan (opsional)

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

  // ── Simpan ─────────────────────────────────────────────────────────────────

  Future<void> handleUpdateCustomer() async {
    if (usernameC.text.trim().isEmpty || nameC.text.trim().isEmpty) {
      _snack("Username dan Nama tidak boleh kosong", isError: true);
      return;
    }
    if (passwordC.text.isNotEmpty && passwordC.text.length < 8) {
      _snack("Password baru harus minimal 8 karakter", isError: true);
      return;
    }
    if (selectedServiceId == null) {
      _snack("Pilih jenis layanan terlebih dahulu", isError: true);
      return;
    }

    setState(() => loading = true);

    try {
      final controller = context.read<CustomerAdminController>();

      int customerId = 0;
      if (widget.customer is Map) {
        customerId = int.tryParse(widget.customer['id'].toString()) ?? 0;
      } else {
        try { customerId = widget.customer.id ?? 0; } catch (_) {}
      }

      final cleanUsername = usernameC.text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');

      final result = await controller.updateCustomer(
        id:             customerId,
        token:          widget.token,
        username:       cleanUsername,
        password:       passwordC.text,
        name:           nameC.text.trim(),
        customerNumber: customerNumberC.text.trim(),
        phone:          phoneC.text.trim(),
        address:        addressC.text.trim(),
        serviceId:      selectedServiceId!,
      );

      if (!mounted) return;

      if (result["success"] == true) {
        _snack("Data customer berhasil diperbarui!", isError: false);
        Navigator.pop(context, true);
      } else {
        _snack(result["message"] ?? "Gagal memperbarui data", isError: true);
      }
    } catch (e) {
      _snack("Terjadi kesalahan: ${e.toString()}", isError: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _snack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

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
          "Edit Customer",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── INFO BANNER ─────────────────────────────────────────
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xffFFF8E6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffFFCC00)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.edit_note_rounded, color: Color(0xffB8860B), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Kosongkan field Password jika tidak ingin menggantinya. Data lama sudah terisi otomatis.",
                      style: TextStyle(fontSize: 12, color: Color(0xff7A5C00), height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            // ── SEKSI: AKUN LOGIN ───────────────────────────────────
            _sectionTitle("Akun Login"),

            _buildInputField("Username", "Contoh: bidin123 (huruf kecil, tanpa spasi)", usernameC),

            _buildPasswordField(),

            // ── SEKSI: DATA PELANGGAN ───────────────────────────────
            _sectionTitle("Data Pelanggan"),

            _buildInputField("Nama Lengkap", "Masukkan nama lengkap", nameC),
            _buildInputField("NIK / No. Meter", "Nomor Induk Kependudukan atau No. Meter", customerNumberC, keyboardType: TextInputType.number),
            _buildInputField("No. Telepon", "Contoh: 081335810890", phoneC, keyboardType: TextInputType.phone),
            _buildInputField("Alamat", "Tuliskan alamat lengkap", addressC, maxLines: 3),

            // ── SEKSI: LAYANAN ──────────────────────────────────────
            _sectionTitle("Layanan"),
            const Text(
              "Pilih paket layanan yang diambil customer",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
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
                      child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: selectedServiceId,
                        hint: const Text("Pilih Layanan"),
                        items: controller.services.map((e) => DropdownMenuItem<int>(value: e.id, child: Text(e.name))).toList(),
                        onChanged: (val) => setState(() => selectedServiceId = val),
                      ),
                    ),
            ),

            const SizedBox(height: 36),

            // ── TOMBOL BATAL ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: loading ? null : () => Navigator.pop(context),
                child: const Text("Batal",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),

            // ── TOMBOL SIMPAN ───────────────────────────────────────
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
                    : const Text("Simpan Perubahan",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Widget helpers ──────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold,
              color: Color(0xff0066FF), letterSpacing: 0.4),
        ),
      );

  Widget _buildInputField(
    String title,
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) =>
      Column(
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
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 18),
        ],
      );

  Widget _buildPasswordField() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Password Baru (Opsional)",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xff1E293B))),
          const SizedBox(height: 8),
          TextField(
            controller: passwordC,
            obscureText: obscurePassword,
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
              hintText: "Kosongkan jika tidak ingin mengganti password",
              filled: true,
              fillColor: const Color(0xffE6E6E6),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey, size: 20,
                ),
                onPressed: () => setState(() => obscurePassword = !obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
      );
}