import 'package:flutter/material.dart';
import 'package:ukl_mobile_uiux/views/login_view.dart';

class RoleView extends StatelessWidget {
  const RoleView({super.key});

  Widget roleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String button,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.blue.shade50,

            child: Icon(icon, color: Colors.blue),
          ),

          const SizedBox(height: 14),

          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),

          const SizedBox(height: 8),

          Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: onTap,

            child: Row(
              children: [
                Text(
                  button,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 5),

                const Icon(Icons.arrow_forward, color: Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,

            colors: [Color(0xff0D6EFD), Color(0xff1E4DB7)],
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Text(
              "Pilih Peran",
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Silakan pilih peran anda yang sesuai",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 30),

            roleCard(
              context: context,
              title: "Pelanggan",
              subtitle:
                  "Bayar tagihan, periksa riwayat penggunaan, dan laporkan masalah layanan air secara instan.",
              button: "Lanjutkan sebagai Customer",
              icon: Icons.water_drop_outlined,

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginView(isAdmin: false),
                  ),
                );
              },
            ),

            roleCard(
              context: context,
              title: "Admin",
              subtitle:
                  "Kelola data pelanggan, pantau infrastruktur, dan selesaikan tiket layanan.",
              button: "Lanjutkan sebagai Admin",
              icon: Icons.admin_panel_settings_outlined,

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginView(isAdmin: true),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
