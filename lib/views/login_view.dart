import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukl_mobile_uiux/controllers/auth_controller.dart';
import 'package:ukl_mobile_uiux/views/customers/dashboard_customers_view.dart';
import 'package:ukl_mobile_uiux/views/notifikasi_login_view.dart';
import 'package:ukl_mobile_uiux/views/register_view.dart';
import 'package:ukl_mobile_uiux/views/admin/dashboard_admin_view.dart'; 

class LoginView extends StatefulWidget {
  final bool isAdmin;

  const LoginView({
    super.key,
    required this.isAdmin,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool hidePassword = true;
  bool rememberMe = false;

  final usernameC = TextEditingController();
  final passwordC = TextEditingController();

  Future<void> login() async {
    if (usernameC.text.trim().isEmpty || passwordC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username dan password wajib diisi"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final authController = Provider.of<AuthController>(context, listen: false);

    try {
      String cleanUsername = usernameC.text.trim();
      if (!widget.isAdmin) {
        cleanUsername = cleanUsername.toLowerCase().replaceAll(RegExp(r'\s+'), '');
      }

      final token = await authController.login(
        username: cleanUsername,
        password: passwordC.text,
        isAdmin: widget.isAdmin,
      );

      if (token != null && token.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login berhasil"),
            backgroundColor: Colors.green,
          ),
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('remember_me', rememberMe);

        if (!mounted) return;

        if (widget.isAdmin) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardAdminView(
                token: token, 
                onMenuTap: (index) {}, 
              ),
            ),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardCustomerView(token: token),
            ),
            (route) => false,
          );
        }

      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Username atau password salah"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal login: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    usernameC.dispose();
    passwordC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 300,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xff0D6EFD), Color(0xff1E4DB7)],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 90,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const Text("Kembali", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text("Username", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: usernameC,
                      decoration: InputDecoration(
                        hintText: "Contoh : Royyan_11",
                        filled: true,
                        fillColor: const Color(0xffF3E5E5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordC,
                      obscureText: hidePassword,
                      decoration: InputDecoration(
                        hintText: "Minimal 8 Karakter",
                        filled: true,
                        fillColor: const Color(0xffF3E5E5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => hidePassword = !hidePassword),
                          icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (value) => setState(() => rememberMe = value ?? false),
                        ),
                        const Text("Keep me signed in"),
                      ],
                    ),
                    const SizedBox(height: 30),
                    
                    Consumer<AuthController>(
                      builder: (context, authProvider, child) {
                        return GestureDetector(
                          onTap: authProvider.isLoading ? null : login,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: const LinearGradient(colors: [Color(0xff0D6EFD), Color(0xff1E4DB7)]),
                            ),
                            child: Center(
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      height: 20, 
                                      width: 20, 
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Belum punya akun? "),
                        GestureDetector(
                          onTap: () {
                            if (widget.isAdmin) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterView()));
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiLoginView()));
                            }
                          },
                          child: const Text("Buat Akun", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}