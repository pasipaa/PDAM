import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukl_mobile_uiux/controllers/tagihan%20controller.dart';

class EditTagihanView extends StatefulWidget {
  final String token;
  final Map<String, dynamic>? billData;

  const EditTagihanView({
    super.key,
    required this.token,
    this.billData,
  });

  @override
  State<EditTagihanView> createState() => _EditTagihanViewState();
}

class _EditTagihanViewState extends State<EditTagihanView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _noMeteranController = TextEditingController();
  final TextEditingController _pemakaianController = TextEditingController();

  int? _selectedMonth;
  int? _selectedYear;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _monthsList = [
    {"value": 1, "name": "Januari"}, {"value": 2, "name": "Februari"},
    {"value": 3, "name": "Maret"},   {"value": 4, "name": "April"},
    {"value": 5, "name": "Mei"},     {"value": 6, "name": "Juni"},
    {"value": 7, "name": "Juli"},    {"value": 8, "name": "Agustus"},
    {"value": 9, "name": "September"}, {"value": 10, "name": "Oktober"},
    {"value": 11, "name": "November"}, {"value": 12, "name": "Desember"},
  ];

  List<int> get _yearsList {
    final now = DateTime.now().year;
    return List.generate(7, (i) => now - 2 + i);
  }

  @override
  void initState() {
    super.initState();
    if (widget.billData != null) {
      _noMeteranController.text = (widget.billData!['measurement_number'] ?? '').toString();
      _pemakaianController.text = (widget.billData!['usage_value'] ?? '').toString();
      _selectedMonth = int.tryParse(widget.billData!['month'].toString());
      _selectedYear  = int.tryParse(widget.billData!['year'].toString());
    }
  }

  @override
  void dispose() {
    _noMeteranController.dispose();
    _pemakaianController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _getNamaBulan(int month) {
    const bulan = [
      "Januari","Februari","Maret","April","Mei","Juni",
      "Juli","Agustus","September","Oktober","November","Desember"
    ];
    return (month >= 1 && month <= 12) ? bulan[month - 1] : '-';
  }

  String _formatRupiah(dynamic value) {
    final number = int.tryParse(value.toString()) ?? 0;
    String result = number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return "Rp $result";
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bill = widget.billData;
    final String customerName = bill?['customer']?['name'] ?? "Pelanggan ${bill?['customer_id'] ?? '-'}";
    final String nik          = bill?['customer']?['nik'] ?? '-';
    final String tipeLayanan  = bill?['service']?['name'] ?? "Umum";
    final bool   isActive     = bill?['customer']?['status'] == 'active' ||
                                bill?['customer']?['is_active'] == true;
    final String periodeAwal  = bill != null
        ? "${_getNamaBulan(int.tryParse(bill['month'].toString()) ?? 1)} ${bill['year'] ?? ''}"
        : '-';
    final String harga        = _formatRupiah(bill?['amount'] ?? 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Tagihan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Info Pelanggan (read-only) ────────────────────────
              _card(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(Icons.person, color: Colors.grey, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(customerName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text("NIK : $nik",
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: [
                              _badge(tipeLayanan, Colors.blue),
                              _badge(isActive ? "Aktif" : "Nonaktif",
                                  isActive ? Colors.green : Colors.red),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Info Tagihan (read-only) ──────────────────────────
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Info Tagihan",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    _infoRow("Periode saat ini", periodeAwal),
                    const SizedBox(height: 6),
                    _infoRow("No. Meteran",
                        bill?['measurement_number']?.toString() ?? '-'),
                    const SizedBox(height: 6),
                    _infoRow("Harga", harga, isPrice: true),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Form Edit ─────────────────────────────────────────
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Ubah Data",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 16),

                    // Bulan & Tahun
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label("Bulan"),
                              _dropdown<int>(
                                value: _selectedMonth,
                                hint: "Pilih Bulan",
                                items: _monthsList
                                    .map((m) => DropdownMenuItem<int>(
                                          value: m['value'] as int,
                                          child: Text(m['name'].toString()),
                                        ))
                                    .toList(),
                                onChanged: _isLoading
                                    ? null
                                    : (v) => setState(() => _selectedMonth = v),
                                validator: (v) =>
                                    v == null ? "Pilih bulan" : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label("Tahun"),
                              _dropdown<int>(
                                value: _selectedYear,
                                hint: "Pilih Tahun",
                                items: _yearsList
                                    .map((y) => DropdownMenuItem<int>(
                                          value: y,
                                          child: Text(y.toString()),
                                        ))
                                    .toList(),
                                onChanged: _isLoading
                                    ? null
                                    : (v) => setState(() => _selectedYear = v),
                                validator: (v) =>
                                    v == null ? "Pilih tahun" : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Nomor Meteran
                    _label("Nomor Meteran"),
                    _textField(
                      controller: _noMeteranController,
                      hint: "Masukkan nomor meteran",
                    ),

                    const SizedBox(height: 14),

                    // Pemakaian
                    _label("Jumlah Pemakaian (m³)"),
                    _textField(
                      controller: _pemakaianController,
                      hint: "Masukkan angka pemakaian",
                      isNumber: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Tombol Batal & Simpan ─────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Batal",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _simpan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F52BA),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text("Simpan",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Simpan ─────────────────────────────────────────────────────────────────

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.billData == null || widget.billData!['id'] == null) {
      _snack("Data tagihan tidak valid!", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    final int billId = int.tryParse(widget.billData!['id'].toString()) ?? 0;
    final Map<String, dynamic> updateData = {
      "month": _selectedMonth,
      "year": _selectedYear,
      "measurement_number": _noMeteranController.text.trim(),
      "usage_value": int.tryParse(_pemakaianController.text.trim()) ?? 0,
    };

    try {
      final controller = context.read<TagihanController>();
      final success = await controller.updateBill(billId, updateData, widget.token);
      if (!mounted) return;
      if (success) {
        _snack("Tagihan berhasil diperbarui!", Colors.green);
        await controller.getBills(widget.token);
        Navigator.pop(context);
      } else {
        _snack("Gagal memperbarui tagihan.", Colors.red);
      }
    } catch (e) {
      if (mounted) _snack("Error: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── Widget helpers ──────────────────────────────────────────────────────────

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: child,
      );

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      );

  Widget _infoRow(String label, String value, {bool isPrice = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(value,
              style: TextStyle(
                color: isPrice ? const Color(0xFF0F52BA) : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: isPrice ? 14 : 13,
              )),
        ],
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
      );

  Widget _textField({
    required TextEditingController controller,
    String hint = '',
    bool isNumber = false,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        enabled: !_isLoading,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          filled: true,
          fillColor: const Color(0xFFEBEBEB),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (v) =>
            v == null || v.trim().isEmpty ? "Field ini wajib diisi" : null,
      );

  Widget _dropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    required String? Function(T?)? validator,
  }) =>
      DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        hint: Text(hint,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFEBEBEB),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.black87, fontSize: 14),
        items: items,
        onChanged: onChanged,
        validator: validator,
      );
}