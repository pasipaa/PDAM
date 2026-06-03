import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NotifikasiLoginView extends StatelessWidget {
  const NotifikasiLoginView({super.key});

  Future<void> _bukaWhatsApp() async {
    final Uri whatsappUrl = Uri.parse("https://wa.me/qr/NOZ5ZUMHTMA4E1");
    if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
      throw Exception('Tidak dapat membuka WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D6EFD),
      body: Stack(
        children: [
          Container(
            height: 300,
            color: const Color(0xff0D6EFD),
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const Spacer(),

                  Image.asset(
                    'assets/hubungi_admin.png',
                    height: 180,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    "Hubungi Admin untuk Registrasi",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0D6EFD),
                    ),
                  ),
                  
                  const SizedBox(height: 8),

                  const Text(
                    "Silahkan Chat Whatsapp Admin di Bawah ini",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const Spacer(),

                  ElevatedButton.icon(
                    onPressed: () {
                      _bukaWhatsApp();
                    },
                    icon: const Icon(Icons.chat, color: Colors.white), 
                    label: const Text(
                      "Chat Admin",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0D6EFD),
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Batal",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xffE5E5E5)),
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}