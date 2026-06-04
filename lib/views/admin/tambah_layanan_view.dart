import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:ukl_mobile_uiux/controllers/layanan_controller.dart';

class TambahLayananView extends StatefulWidget {
  final String token;
  final Map<String, dynamic> dataLayanan;

  const TambahLayananView({
    super.key,
    required this.token,
    required this.dataLayanan,
  });

  @override
  State<TambahLayananView> createState() => _TambahLayananViewState();
}

class _TambahLayananViewState extends State<TambahLayananView> {
  final namaC = TextEditingController();
  final minUsageC = TextEditingController();
  final maxUsageC = TextEditingController();
  final hargaC = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // 🔹 Mode edit jika dataLayanan tidak kosong dan punya 'id'
  bool get isEditMode =>
      widget.dataLayanan.isNotEmpty && widget.dataLayanan['id'] != null;

  @override
  void initState() {
    super.initState();
    // 🔹 Isi field hanya saat mode edit
    if (isEditMode) {
      namaC.text = widget.dataLayanan['name']?.toString() ?? '';
      minUsageC.text = widget.dataLayanan['min_usage']?.toString() ?? '';
      maxUsageC.text = widget.dataLayanan['max_usage']?.toString() ?? '';
      hargaC.text = widget.dataLayanan['price']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    namaC.dispose();
    minUsageC.dispose();
    maxUsageC.dispose();
    hargaC.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      if (!kIsWeb && Platform.isWindows) {
        FilePickerResult? result = await FilePicker.pickFiles(
          type: FileType.image,
        );
        if (result != null && result.files.single.path != null) {
          setState(() {
            _selectedImage = File(result.files.single.path!);
          });
        }
      } else {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (pickedFile != null) {
          setState(() {
            _selectedImage = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal mengambil foto: $e");
    }
  }

  bool _validateFields() {
    if (namaC.text.isEmpty ||
        minUsageC.text.isEmpty ||
        maxUsageC.text.isEmpty ||
        hargaC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua kolom wajib diisi!")),
      );
      return false;
    }
    return true;
  }

  /// 🔹 PROSES TAMBAH DATA BARU — memanggil createLayanan
  Future<void> handleTambahLayanan(LayananController controller) async {
    if (!_validateFields()) return;

    final success = await controller.createLayanan(
      token: widget.token,
      name: namaC.text,
      minUsage: int.parse(minUsageC.text),
      maxUsage: int.parse(maxUsageC.text),
      price: int.parse(hargaC.text),
      image: _selectedImage,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Layanan berhasil ditambahkan"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal menambahkan layanan"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 🔹 PROSES UPDATE DATA
  Future<void> handleUpdateLayanan(LayananController controller) async {
    if (!_validateFields()) return;

    final success = await controller.updateLayanan(
      id: widget.dataLayanan['id'],
      name: namaC.text,
      minUsage: int.parse(minUsageC.text),
      maxUsage: int.parse(maxUsageC.text),
      price: int.parse(hargaC.text),
      token: widget.token,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Layanan berhasil diperbarui"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal memperbarui data"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 🔹 PROSES HAPUS DATA — hanya di mode edit
  void konfirmasiHapus(LayananController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Layanan"),
        content: const Text("Apakah Anda yakin ingin menghapus layanan ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await controller.deleteLayanan(
                widget.dataLayanan['id'],
                widget.token,
              );
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Layanan berhasil dihapus"),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context, true);
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layananController = context.watch<LayananController>();

    return Scaffold(
      backgroundColor: const Color(0xffF4F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F8FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditMode ? "Ubah Layanan" : "Tambah Layanan",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          // 🔹 Tombol hapus hanya muncul di mode edit
          if (isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xffD32424), size: 26),
              onPressed: () => konfirmasiHapus(layananController),
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Icon (format .svg / .jpg)",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2A3238),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 130,
                        decoration: BoxDecoration(
                          color: const Color(0xffEAECEF).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedImage == null
                            ? Center(
                                child: Icon(
                                  Icons.add_photo_alternate_rounded,
                                  size: 42,
                                  color: const Color(0xff0066FF).withOpacity(0.8),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildInputField(
                      controller: namaC,
                      title: "Nama Layanan",
                      hint: "Tulis nama layanan",
                    ),
                    const SizedBox(height: 18),
                    buildInputField(
                      controller: minUsageC,
                      title: "Minimal Pemakaian (m³)",
                      hint: "Masukkan Angkanya",
                      number: true,
                    ),
                    const SizedBox(height: 18),
                    buildInputField(
                      controller: maxUsageC,
                      title: "Max Pemakaian (m³)",
                      hint: "Masukkan Angkanya",
                      number: true,
                    ),
                    const SizedBox(height: 18),
                    buildInputField(
                      controller: hargaC,
                      title: "Harga per m³ (Rupiah)",
                      hint: "Masukkan Angkanya",
                      number: true,
                    ),
                  ],
                ),
              ),
            ),

            // 🔹 BOTTOM BUTTONS
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xffD32424), width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Batal",
                        style: TextStyle(
                            color: Color(0xffD32424),
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0066FF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: layananController.isLoading
                          ? null
                          : () {
                              if (isEditMode) {
                                handleUpdateLayanan(layananController);
                              } else {
                                handleTambahLayanan(layananController);
                              }
                            },
                      child: layananController.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isEditMode ? "Simpan Perubahan" : "Tambah Layanan",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String title,
    required String hint,
    bool number = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xff2A3238)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: number ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontSize: 15, color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                fontWeight: FontWeight.w400),
            filled: true,
            fillColor: const Color(0xffEAECEF).withOpacity(0.6),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}