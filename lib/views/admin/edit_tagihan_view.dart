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

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _noMeteranController = TextEditingController();
  final TextEditingController _pemakaianController = TextEditingController();

  int? _selectedMonth;
  int _selectedYear = 2026;

  final List<Map<String, dynamic>> _monthsList = [
    {"value": 1, "name": "Januari"},
    {"value": 2, "name": "Februari"},
    {"value": 3, "name": "Maret"},
    {"value": 4, "name": "April"},
    {"value": 5, "name": "Mei"},
    {"value": 6, "name": "Juni"},
    {"value": 7, "name": "Juli"},
    {"value": 8, "name": "Agustus"},
    {"value": 9, "name": "September"},
    {"value": 10, "name": "Oktober"},
    {"value": 11, "name": "November"},
    {"value": 12, "name": "Desember"},
  ];

  final List<int> _yearsList = [2024, 2025, 2026, 2027, 2028, 2029, 2030];
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    
    if (widget.billData != null) {
      _idController.text = (widget.billData!['customer_id'] ?? 
                            widget.billData!['customer']?['id'] ?? '').toString();
      _noMeteranController.text = (widget.billData!['measurement_number'] ?? '').toString();
      _pemakaianController.text = (widget.billData!['usage_value'] ?? '').toString();

      int monthNumber = int.tryParse(widget.billData!['month'].toString()) ?? 3;
      if (monthNumber >= 1 && monthNumber <= 12) {
        _selectedMonth = monthNumber;
      }

      int yearNum = int.tryParse(widget.billData!['year'].toString()) ?? 2026;
      if (_yearsList.contains(yearNum)) {
        _selectedYear = yearNum;
      }
    } else {
      _idController.text = "1091"; 
      _noMeteranController.text = "000041";
      _pemakaianController.text = "26";
      _selectedMonth = 3;
      _selectedYear = 2026;
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _noMeteranController.dispose();
    _pemakaianController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Tagihan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('ID Pelanggan (Tidak dapat diubah)'),
              _buildTextField(_idController, isNumber: true, readOnly: true), 
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Bulan Periode'),
                        _buildDropdown<int>(
                          value: _selectedMonth,
                          hint: "Pilih Bulan",
                          items: _monthsList.map((month) {
                            return DropdownMenuItem<int>(
                              value: month['value'] as int,
                              child: Text(month['name'].toString()),
                            );
                          }).toList(),
                          onChanged: _isLoading ? null : (val) {
                            setState(() {
                              _selectedMonth = val;
                            });
                          },
                          validator: (value) => value == null ? "Silakan pilih bulan" : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Tahun'),
                        _buildDropdown<int>(
                          value: _selectedYear,
                          hint: "Pilih Tahun",
                          items: _yearsList.map((year) {
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }).toList(),
                          onChanged: _isLoading ? null : (val) {
                            setState(() {
                              if (val != null) _selectedYear = val;
                            });
                          },
                          validator: (value) => value == null ? "Silakan pilih tahun" : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Nomor Meteran Air (Measurement)'),
              _buildTextField(_noMeteranController, hint: "Masukkan nomor meteran air"),
              const SizedBox(height: 16),

              _buildLabel('Jumlah Pemakaian Air (m³)'),
              _buildTextField(_pemakaianController, isNumber: true, hint: "Masukkan angka pemakaian air"),
            ],
          ),
        ),
      ),
      
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0061FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      if (widget.billData == null || widget.billData!['id'] == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Data tagihan tidak valid!"), backgroundColor: Colors.red),
                        );
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      int billId = int.tryParse(widget.billData!['id'].toString()) ?? 0;

                      /* PENTING: Sesuai aturan API, hanya kirim field yang diperbolehkan di-ubah
                         untuk menghindari bug validasi keunikan data di server. 
                      */
                      Map<String, dynamic> updateData = {
                        "measurement_number": _noMeteranController.text.trim(),
                        "usage_value": int.tryParse(_pemakaianController.text.trim()) ?? 0,
                      };

                      debugPrint("Data PATCH siap dikirim ke ID $billId: $updateData");

                      try {
                        final controller = context.read<TagihanController>();
                        bool success = await controller.updateBill(billId, updateData, widget.token);

                        if (!mounted) return;

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tagihan berhasil diperbarui!'), backgroundColor: Colors.green),
                          );
                          await controller.getBills(widget.token); 
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gagal memperbarui data tagihan!'), backgroundColor: Colors.red),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    }
                  },
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Simpan Edit Tagihan',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, {bool isNumber = false, bool readOnly = false, String hint = ""}) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? const Color(0xFFDCDCDC) : const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        enabled: !_isLoading,
        style: TextStyle(
          color: readOnly ? Colors.black38 : Colors.black54, 
          fontSize: 14, 
          fontWeight: FontWeight.w600
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.normal),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (value) => value == null || value.trim().isEmpty ? "Data ini tidak boleh kosong" : null,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    required String? Function(T?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.normal)),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black87),
          style: const TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w600),
          dropdownColor: Colors.white,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          items: items,
          onChanged: onChanged,
          validator: validator,
        ),
      ),
    );
  }
}