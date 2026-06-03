import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ukl_mobile_uiux/controllers/customers/customers_controller.dart';

class DetailBayarView extends StatefulWidget {
  final Map<String, dynamic> bill;
  final String token;

  const DetailBayarView({super.key, required this.bill, required this.token, required String dynamicStatus});

  @override
  State<DetailBayarView> createState() => _DetailBayarViewState();
}

class _DetailBayarViewState extends State<DetailBayarView> {
  final _controller = CustomerController();
  XFile? _selectedImage;
  bool _isLoading = false;
  
  int _currentStep = 1; 
  bool _isUploadFailed = false;
  String _selectedMethod = "QRIS";

  final List<Map<String, String>> _paymentMethods = [
    {"name": "QRIS", "logo": "assets/qris.png"}, 
    {"name": "Gopay", "logo": "assets/gopay.png"},
    {"name": "OVO", "logo": "assets/ovo.png"},
    {"name": "DANA", "logo": "assets/dana.png"},
    {"name": "BCA", "logo": "assets/bca.png"},
    {"name": "ShopeePay", "logo": "assets/shopeepay.png"},
  ];

  Future<void> _pickProofImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
        _isUploadFailed = false; 
      });
    }
  }

  Future<void> _submitPayment() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan unggah bukti pembayaran terlebih dahulu!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      String billId = widget.bill["id"].toString();

      bool isSuccess = await _controller.uploadPayment(
        billId,
        _selectedImage!.path,
        widget.token,
      );

      if (!mounted) return;
      setState(() { _isLoading = false; });

      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bukti pembayaran berhasil dikirim!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); 
      } else {
        setState(() {
          _isUploadFailed = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { 
        _isLoading = false; 
        _isUploadFailed = true;
      });
      debugPrint("Error saat submit pembayaran: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F8FB),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xff1E293B), size: 20),
          onPressed: _isLoading 
              ? null 
              : () {
                  if (_currentStep == 2) {
                    setState(() { 
                      _currentStep = 1; 
                      _isUploadFailed = false;
                    });
                  } else {
                    Navigator.pop(context);
                  }
                },
        ),
        title: Text(
          _currentStep == 1 ? "Pembayaran" : "Bukti Pembayaran",
          style: const TextStyle(color: Color(0xff1E293B), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentStep == 1
              ? _buildMethodSelectionScreen() 
              : _buildUploadScreen(), 
    );
  }

  Widget _buildMethodSelectionScreen() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBillRow("Periode", widget.bill["periode"]?.toString() ?? "-"),
                _buildBillRow("Pemakaian", "${widget.bill["pemakaian"]?.toString() ?? "-"} m³"),
                _buildBillRow("Harga", widget.bill["harga"]?.toString() ?? "0", isPrice: true),
                const SizedBox(height: 24),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _paymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = _paymentMethods[index];
                    final bool isSelected = _selectedMethod == method["name"];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xff0A59D1) : Colors.grey.shade100, 
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            method["logo"]!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.payment, color: Color(0xff0A59D1), size: 24);
                            },
                          ),
                        ),
                        title: Text(
                          method["name"]!,
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff1E293B)),
                        ),
                        trailing: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? const Color(0xff0A59D1) : Colors.grey.shade300,
                          ),
                          child: isSelected 
                              ? const Icon(Icons.check, color: Colors.white, size: 12) 
                              : null,
                        ),
                        onTap: () {
                          setState(() { _selectedMethod = method["name"]!; });
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        _buildBottomButton("Bayar Via $_selectedMethod", () {
          setState(() { _currentStep = 2; });
        }),
      ],
    );
  }

  Widget _buildUploadScreen() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              height: 380,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200, width: 1.2),
              ),
              child: _buildDynamicCardContent(),
            ),
          ),
        ),
        _buildBottomButton(_isUploadFailed ? "Coba Lagi" : "Kirim Bukti", _submitPayment),
      ],
    );
  }

  Widget _buildDynamicCardContent() {
    if (_isUploadFailed) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cancel, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            "Upload Gagal",
            style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Terjadi kendala saat mengirim data ke server.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xff64748B), fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _pickProofImage,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
            label: const Text("Pilih File Baru", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff0A59D1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          )
        ],
      );
    } else if (_selectedImage != null) {
      return Column(
        children: [
          const Text(
            "Pratinjau Bukti Transfer",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff1E293B), fontSize: 14),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(_selectedImage!.path),
                fit: BoxFit.contain,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _pickProofImage,
            icon: const Icon(Icons.edit, size: 16),
            label: const Text("Ganti Foto"),
          )
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_upload_outlined, size: 64, color: Color(0xff0A59D1)),
          const SizedBox(height: 16),
          const Text(
            "Upload Bukti Pembayaran",
            style: TextStyle(color: Color(0xff1E293B), fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Format file didukung: JPG, PNG",
            style: TextStyle(color: Color(0xff64748B), fontSize: 12),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _pickProofImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff0A59D1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Pilih Gambar", style: TextStyle(color: Colors.white)),
          )
        ],
      );
    }
  }

  Widget _buildBillRow(String label, String value, {bool isPrice = false}) {
    String displayValue = value;
    
    if (isPrice && !value.startsWith('Rp')) {
      final number = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
      if (number != null) {
        displayValue = "Rp ${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
      } else {
        displayValue = "Rp $value";
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xff64748B), fontSize: 14)),
          Text(
            displayValue,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isPrice ? 16 : 14,
              color: isPrice ? const Color(0xff0A59D1) : const Color(0xff1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff0A59D1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}