import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukl_mobile_uiux/controllers/customers/customers_controller.dart';

class CustEditProfileView extends StatefulWidget {
  final String token;
  const CustEditProfileView({super.key, required this.token});

  @override
  State<CustEditProfileView> createState() => _CustEditProfileViewState();
}

class _CustEditProfileViewState extends State<CustEditProfileView> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller untuk form input
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    // Mengambil data profile saat ini dari controller
    final currentProfile = Provider.of<CustomerController>(context, listen: false).profile;

    // Inisialisasi text controller dengan data lama pelanggan
    _nameController = TextEditingController(text: currentProfile?.name ?? "");
    _phoneController = TextEditingController(text: currentProfile?.phone ?? "");
    _addressController = TextEditingController(text: currentProfile?.address ?? "");
    _usernameController = TextEditingController(text: currentProfile?.username ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Provider.of<CustomerController>(context, listen: false);
    
    // Panggil fungsi update di CustomerController kamu
    // Sederhananya kita asumsikan fungsinya menerima token dan map data baru
    bool success = await controller.updateProfile(
      token: widget.token,
      name: _nameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      username: _usernameController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profil berhasil diperbarui!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Kembali ke ProfilCustView dan otomatis auto-refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? "Gagal memperbarui profil."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F8FB),
      appBar: AppBar(
        title: const Text(
          "Edit Profil",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff063A69), fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xff063A69), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<CustomerController>(
        builder: (context, controller, child) {
          return Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        // Avatar Section
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.blue.shade50,
                                backgroundImage: const AssetImage('assets/images/stitch_profile.png'),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xff3B82F6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Input fields
                        _buildTextField("Nama Lengkap", _nameController, Icons.person_outline),
                        const SizedBox(height: 18),
                        _buildTextField("Username", _usernameController, Icons.alternate_email_rounded),
                        const SizedBox(height: 18),
                        _buildTextField("No. Telepon", _phoneController, Icons.phone_android_rounded, keyboardType: TextInputType.phone),
                        const SizedBox(height: 18),
                        _buildTextField("Alamat", _addressController, Icons.home_outlined, maxLines: 3),
                        
                        const SizedBox(height: 50),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: controller.isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff3B82F6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: controller.isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text(
                                    "Simpan Perubahan",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                            ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, 
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff1E293B), fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: Color(0xff063A69), fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade100, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xff3B82F6), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "$label tidak boleh kosong";
            }
            return null;
          },
        ),
      ],
    );
  }
}