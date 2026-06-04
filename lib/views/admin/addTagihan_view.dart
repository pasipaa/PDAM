import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukl_mobile_uiux/controllers/customer_controller.dart';
import 'package:ukl_mobile_uiux/controllers/tagihan%20controller.dart';

class TambahTagihanView extends StatefulWidget {
  final String token;
  const TambahTagihanView({super.key, required this.token});

  @override
  State<TambahTagihanView> createState() => _TambahTagihanViewState();
}

class _TambahTagihanViewState extends State<TambahTagihanView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _meteranController = TextEditingController();
  final TextEditingController _pemakaianController = TextEditingController();

  dynamic _selectedCustomer;
  int? _selectedMonth;
  int? _selectedYear;

  final List<Map<String, dynamic>> _months = [
    {"label": "Januari", "value": 1},
    {"label": "Februari", "value": 2},
    {"label": "Maret", "value": 3},
    {"label": "April", "value": 4},
    {"label": "Mei", "value": 5},
    {"label": "Juni", "value": 6},
    {"label": "Juli", "value": 7},
    {"label": "Agustus", "value": 8},
    {"label": "September", "value": 9},
    {"label": "Oktober", "value": 10},
    {"label": "November", "value": 11},
    {"label": "Desember", "value": 12},
  ];

  List<int> get _years {
    final currentYear = DateTime.now().year;
    return List.generate(5, (i) => currentYear - 2 + i);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerAdminController>(context, listen: false)
          .getCustomers(widget.token);
    });
  }

  @override
  void dispose() {
    _meteranController.dispose();
    _pemakaianController.dispose();
    super.dispose();
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xffEBEBEB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerController = Provider.of<CustomerAdminController>(context);
    final tagihanController = Provider.of<TagihanController>(context);

    return Scaffold(
      backgroundColor: const Color(0xffF4F8FA),
      appBar: AppBar(
        title: const Text("Tambah Tagihan"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Pelanggan ──────────────────────────────────
                _buildLabel("Pelanggan"),
                DropdownButtonFormField<dynamic>(
                  decoration: _inputDecoration(),
                  hint: customerController.isLoading
                      ? const Text("Memuat...")
                      : const Text("Pilih Pelanggan"),
                  value: _selectedCustomer,
                  items: customerController.customers
                      .map((c) => DropdownMenuItem(value: c, child: Text("${c.name}")))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCustomer = val),
                  validator: (val) => val == null ? "Pilih pelanggan" : null,
                ),
                const SizedBox(height: 16),

                // ── Bulan ──────────────────────────────────────
                _buildLabel("Bulan"),
                DropdownButtonFormField<int>(
                  decoration: _inputDecoration(),
                  hint: const Text("Pilih Bulan"),
                  value: _selectedMonth,
                  items: _months
                      .map((m) => DropdownMenuItem<int>(
                            value: m["value"],
                            child: Text(m["label"]),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedMonth = val),
                  validator: (val) => val == null ? "Pilih bulan" : null,
                ),
                const SizedBox(height: 16),

                // ── Tahun ──────────────────────────────────────
                _buildLabel("Tahun"),
                DropdownButtonFormField<int>(
                  decoration: _inputDecoration(),
                  hint: const Text("Pilih Tahun"),
                  value: _selectedYear,
                  items: _years
                      .map((y) => DropdownMenuItem<int>(value: y, child: Text("$y")))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedYear = val),
                  validator: (val) => val == null ? "Pilih tahun" : null,
                ),
                const SizedBox(height: 16),

                // ── Nomor Meteran ──────────────────────────────
                _buildLabel("Nomor Meteran"),
                TextFormField(
                  controller: _meteranController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(),
                  validator: (val) => val!.isEmpty ? "Nomor meteran wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                // ── Jumlah Pemakaian ───────────────────────────
                _buildLabel("Jumlah Pemakaian (m³)"),
                TextFormField(
                  controller: _pemakaianController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(),
                  validator: (val) => val!.isEmpty ? "Pemakaian wajib diisi" : null,
                ),
                const SizedBox(height: 32),

                // ── Tombol Simpan ──────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: tagihanController.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              final dataTagihan = {
                                "customer_id": _selectedCustomer.id,
                                "month": _selectedMonth,
                                "year": _selectedYear,
                                "measurement_number": _meteranController.text,
                                "usage_value": int.tryParse(_pemakaianController.text) ?? 0,
                              };
                              tagihanController
                                  .createBill(dataTagihan, widget.token)
                                  .then((success) {
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Tagihan berhasil ditambahkan!"),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  Navigator.pop(context, true);
                                }
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F52BA),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: tagihanController.isLoading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            "Simpan Tagihan",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}