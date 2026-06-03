import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukl_mobile_uiux/controllers/tagihan%20controller.dart';
import 'package:ukl_mobile_uiux/controllers/customers/customers_controller.dart'; 

class AddTagihanView extends StatefulWidget {
  final String token;

  const AddTagihanView({super.key, required this.token});

  @override
  State<AddTagihanView> createState() => _AddTagihanViewState();
}

class _AddTagihanViewState extends State<AddTagihanView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _measurementController = TextEditingController(); 
  final TextEditingController _usageController = TextEditingController();

  int? _selectedCustomerId;
  int? _selectedMonth;
  int _selectedYear = 2026;
  
  bool _isLoading = false;
  bool _isLoadingCustomers = false;
  List<dynamic> _customersList = []; 

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCustomersData();
    });
  }

  Future<void> _loadCustomersData() async {
    setState(() {
      _isLoadingCustomers = true;
    });

    try {
      final customerController = Provider.of<CustomerController>(context, listen: false);
      
      await customerController.getCustomers(widget.token); 
      
      if (mounted) {
        setState(() {
          _customersList = customerController.customers!;
        });
      }
    } catch (e) {
      debugPrint("Gagal memuat data pelanggan: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data pelanggan!"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCustomers = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _measurementController.dispose();
    _usageController.dispose();
    super.dispose();
  }

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      if (_isLoading) return;

      setState(() {
        _isLoading = true;
      });

      try {
        final tagihanController = context.read<TagihanController>();
        
        Map<String, dynamic> bodyData = {
          "customer_id": _selectedCustomerId,
          "month": _selectedMonth, 
          "year": _selectedYear,   
          "measurement_number": _measurementController.text.trim(), 
          "usage_value": int.tryParse(_usageController.text.trim()) ?? 0,
        };
        
        bool success = await tagihanController.createBill(bodyData, widget.token);
        
        if (!mounted) return;
        
        if (success) {
          await tagihanController.getBills(widget.token);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tagihan baru berhasil disimpan!"), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan data: $e"), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
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
          'Tambah Tagihan', 
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
              _buildLabel('Pilih Pelanggan (Customer)'),
              _isLoadingCustomers 
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 10),
                        Text("Memuat data pelanggan...", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  )
                : _buildDropdown<int>(
                    value: _selectedCustomerId,
                    hint: _customersList.isEmpty ? "Tidak ada data pelanggan" : "Pilih Nama Pelanggan",
                    items: _customersList.map((customer) {
                      final id = customer is Map ? customer['id'] : customer.id;
                      final name = customer is Map ? customer['name'] : customer.name;

                      return DropdownMenuItem<int>(
                        value: int.tryParse(id.toString()), 
                        child: Text("$name (ID: $id)"), 
                      );
                    }).toList(),
                    onChanged: _isLoading || _customersList.isEmpty ? null : (val) {
                      setState(() {
                        _selectedCustomerId = val;
                      });
                    },
                    validator: (value) => value == null ? "Silakan pilih pelanggan" : null,
                  ),
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
                              _selectedYear = val!;
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
              
              _buildLabel('Nomor Meteran'),
              _buildTextField(
                controller: _measurementController,
                hint: "Masukkan no meteran",
                validator: (val) => val == null || val.trim().isEmpty ? "Nomor meter wajib diisi" : null,
              ),
              
              const SizedBox(height: 16),
              
              _buildLabel('Pemakaian (m³)'),
              _buildTextField(
                controller: _usageController,
                hint: "Contoh: 20",
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.trim().isEmpty ? "Pemakaian wajib diisi" : null,
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0A59D1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 20, width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text(
                        "Simpan Tagihan", 
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text, 
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
    required String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.blue)),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.blue)),
      ),
    );
  }
}