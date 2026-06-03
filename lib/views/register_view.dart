import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ukl_mobile_uiux/services/url.dart' as url;
import 'login_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final nameC = TextEditingController();
  final usernameC = TextEditingController();
  final phoneC = TextEditingController();
  final passwordC = TextEditingController();
  final confirmPasswordC = TextEditingController();

  bool hidePassword = true;
  bool isRegistering = false;

  @override
  void dispose() {
    nameC.dispose();
    usernameC.dispose();
    phoneC.dispose();
    passwordC.dispose();
    confirmPasswordC.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (nameC.text.isEmpty ||
        usernameC.text.isEmpty ||
        phoneC.text.isEmpty ||
        passwordC.text.isEmpty ||
        confirmPasswordC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua field wajib diisi"),
        ),
      );
      return;
    }

    if (passwordC.text != confirmPasswordC.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Konfirmasi password tidak sama"),
        ),
      );
      return;
    }

    setState(() {
      isRegistering = true;
    });

    try {
      final response = await http.post(
        Uri.parse("${url.BaseUrl}/admins"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "APP-KEY": "c37f844fd9ee042b180261eb49bf457d6e3a5184", 
        },
        body: jsonEncode({
          "username": usernameC.text.trim(),
          "password": passwordC.text.trim(),
          "name": nameC.text.trim(),
          "phone": phoneC.text.trim(),
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Register berhasil! Silakan login."),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      } else {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Register gagal, periksa data kembali"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal terhubung ke server: Server sibuk atau cek koneksi internet Anda."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isRegistering = false;
        });
      }
    }
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xffF3E5E5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
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
                colors: [
                  Color(0xff0D6EFD),
                  Color(0xff1E4DB7),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.82,
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
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const Text("Kembali"),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text("Nama Lengkap"),
                    const SizedBox(height: 8),

                    TextField(
                      controller: nameC,
                      decoration:
                          inputDecoration("Contoh : Budi Santoso"),
                    ),

                    const SizedBox(height: 16),

                    const Text("Username"),
                    const SizedBox(height: 8),

                    TextField(
                      controller: usernameC,
                      decoration:
                          inputDecoration("Contoh : Royyan_11"),
                    ),

                    const SizedBox(height: 16),

                    const Text("Nomor Telepon"),
                    const SizedBox(height: 8),

                    TextField(
                      controller: phoneC,
                      keyboardType: TextInputType.phone,
                      decoration:
                          inputDecoration("Gunakan +62 diawal"),
                    ),

                    const SizedBox(height: 16),

                    const Text("Password"),
                    const SizedBox(height: 8),

                    TextField(
                      controller: passwordC,
                      obscureText: hidePassword,
                      decoration: InputDecoration(
                        hintText: "Minimal 8 Karakter",
                        filled: true,
                        fillColor: const Color(0xffF3E5E5),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text("Konfirmasi Password"),
                    const SizedBox(height: 8),

                    TextField(
                      controller: confirmPasswordC,
                      obscureText: hidePassword,
                      decoration: InputDecoration(
                        hintText:
                            "Masukkan Ulang Password",
                        filled: true,
                        fillColor: const Color(0xffF3E5E5),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    GestureDetector(
                      onTap: isRegistering ? null : register,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xff0D6EFD),
                              Color(0xff1E4DB7),
                            ],
                          ),
                        ),
                        child: Center(
                          child: isRegistering
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Register",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Sudah punya akun? ",
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const LoginView(
                                  isAdmin: true,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight:
                                  FontWeight.bold,
                              ),
                          ),
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