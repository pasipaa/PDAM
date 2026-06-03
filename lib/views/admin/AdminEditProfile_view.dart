import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukl_mobile_uiux/controllers/profile_controller.dart';

class EditProfileView extends StatefulWidget {
  final String token;
  const EditProfileView({super.key, required this.token});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profileController = Provider.of<ProfileController>(context, listen: false);
    final currentAdmin = profileController.profile;

    _nameController = TextEditingController(text: currentAdmin?.name ?? "");
    _phoneController = TextEditingController(text: currentAdmin?.phone ?? "");
    
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final profileController = Provider.of<ProfileController>(context, listen: false);
      
      try {
        bool success = await profileController.updateAdminProfile(
          token: widget.token,
          name: _nameController.text,
          phone: _phoneController.text,
          password: _newPasswordController.text.isNotEmpty ? _newPasswordController.text : null,
        );
        
        setState(() => _isLoading = false);

        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perubahan profil berhasil disimpan!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(profileController.errorMessage ?? 'Gagal menyimpan perubahan profil.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Terjadi kesalahan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F8FA),
      body: Stack(
        children: [
          Positioned(top: 150, left: -40, child: _buildBgCircle(const Color(0xff0066FF).withOpacity(0.1), 110)),
          Positioned(top: -30, right: 40, child: _buildBgCircle(const Color(0xff0066FF).withOpacity(0.1), 130)),
          Positioned(top: 240, right: -50, child: _buildBgCircle(const Color(0xff0066FF).withOpacity(0.15), 140)),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xff004080), size: 22),
                              ),
                              const Expanded(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 48.0),
                                    child: Text(
                                      "Edit Profil Admin",
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff004080)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),

                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: CircleAvatar(
                                radius: 70,
                                backgroundColor: Colors.blue.shade50,
                                child: const Icon(Icons.admin_panel_settings_rounded, size: 80, color: Color(0xff004080)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 35),

                          const Center(
                            child: Text(
                              "Data Admin",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xff2D2D2D)),
                            ),
                          ),
                          const SizedBox(height: 20),

                          _buildInputField(
                            label: "Nama Lengkap",
                            controller: _nameController,
                            hintText: "Masukkan nama admin",
                            validator: (val) => val!.isEmpty ? "Nama tidak boleh kosong" : null,
                          ),
                          const SizedBox(height: 20),

                          _buildInputField(
                            label: "Nomor Telepon",
                            controller: _phoneController,
                            hintText: "Masukkan nomor telepon",
                            keyboardType: TextInputType.phone,
                            validator: (val) => val!.isEmpty ? "Nomor telepon tidak boleh kosong" : null,
                          ),
                          const SizedBox(height: 40),

                          const Center(
                            child: Text(
                              "Ganti Password",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xff2D2D2D)),
                            ),
                          ),
                          const SizedBox(height: 20),

                          _buildInputField(
                            label: "Password Saat Ini",
                            controller: _oldPasswordController,
                            hintText: "Masukkan Password saat ini",
                            obscureText: _obscureOldPassword,
                            isPassword: true,
                            onToggleVisibility: () {
                              setState(() => _obscureOldPassword = !_obscureOldPassword);
                            },
                          ),
                          const SizedBox(height: 20),

                          _buildInputField(
                            label: "Password Baru",
                            controller: _newPasswordController,
                            hintText: "Masukkan Password baru",
                            obscureText: _obscureNewPassword,
                            isPassword: true,
                            onToggleVisibility: () {
                              setState(() => _obscureNewPassword = !_obscureNewPassword);
                            },
                          ),
                          const SizedBox(height: 20),

                          _buildInputField(
                            label: "Konfirmasi Password Baru",
                            controller: _confirmPasswordController,
                            hintText: "Ulangi Password baru",
                            obscureText: _obscureConfirmPassword,
                            isPassword: true,
                            onToggleVisibility: () {
                              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                            },
                            validator: (val) {
                              if (_newPasswordController.text.isNotEmpty && val != _newPasswordController.text) {
                                return "Konfirmasi password tidak cocok";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),

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
                              borderRadius: BorderRadius.circular(14),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              color: Color(0xffD32424),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isLoading ? null : _handleSaveChanges,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text(
                                  "Simpan Perubahan",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBgCircle(Color color, double size) => Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff2D2D2D), fontSize: 14)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Color(0xff555555), fontWeight: FontWeight.w500, fontSize: 14),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal, fontSize: 14),
            suffixIcon: isPassword
                ? IconButton(icon: Icon(obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey.shade500, size: 20), onPressed: onToggleVisibility)
                : null,
            filled: true,
            fillColor: const Color(0xffEAEAEA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xff3B97FF), width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
          ),
        ),
      ],
    );
  }
}