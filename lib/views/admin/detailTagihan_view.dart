import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukl_mobile_uiux/controllers/tagihan%20controller.dart';

class DetailTagihanView extends StatelessWidget {
  final String token;
  final Map<String, dynamic> bill;

  const DetailTagihanView({super.key, required this.token, required this.bill});

  String formatRupiah(dynamic value) {
    final number = int.tryParse(value.toString()) ?? 0;
    final String result = number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return "Rp $result";
  }

  String getNamaBulan(int? month) {
    if (month == null) return '-';
    const bulan = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    return (month >= 1 && month <= 12) ? bulan[month - 1] : '-';
  }

  @override
  Widget build(BuildContext context) {
    final tagihanController = context.watch<TagihanController>();

    final String customerName =
        bill['customer']?['name'] ?? "Pelanggan ${bill['customer_id']}";
    final String nik = bill['customer']?['customer_number'] ??
        bill['customer']?['nik'] ??
        '-';
    final String tipeLayanan = bill['service']?['name'] ?? "Umum";
    final bool isActive = bill['customer']?['status'] == 'active' ||
        bill['customer']?['is_active'] == true;

    final int? monthInt = int.tryParse(bill['month']?.toString() ?? '');
    final String periodeText =
        "${getNamaBulan(monthInt)} ${bill['year'] ?? ''}";
    final String pemakaianText = "${bill['usage_value'] ?? '0'} m³";
    final String hargaText =
        formatRupiah(bill['total_price'] ?? bill['amount'] ?? 0);

    // payments adalah Map tunggal (bukan List)
    final payments = bill['payments'];
    final Map<String, dynamic>? paymentMap =
        payments is Map<String, dynamic> ? payments : null;

    // FIXED: Gunakan /payment-proof/:filename sesuai Postman collection
    String? proofUrl;
    if (paymentMap != null) {
      final proof = paymentMap['payment_proof']?.toString();
      if (proof != null && proof.isNotEmpty) {
        if (proof.startsWith('http')) {
          proofUrl = proof;
        } else {
          // Ambil filename saja (bukan full path), lalu pakai endpoint yang benar
          final filename = proof.split('/').last;
          proofUrl =
              "https://learn.smktelkom-mlg.sch.id/pdam/payment-proof/$filename";
        }
      }
    }

    final int billId = int.tryParse(bill['id'].toString()) ?? 0;
    final bool isProcessing =
        tagihanController.processingBillIds.contains(billId);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Verifikasi Tagihan",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Info Pelanggan ────────────────────────────────────
            _card(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey.shade200,
                    child:
                        const Icon(Icons.person, color: Colors.grey, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customerName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text("NIK : $nik",
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: [
                            _badge(tipeLayanan, Colors.blue),
                            _badge(isActive ? "Aktif" : "Nonaktif",
                                isActive ? Colors.green : Colors.red),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Detail Pembayaran ─────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Detail Pembayaran",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 14),
                  _infoRow("Periode", periodeText),
                  const SizedBox(height: 8),
                  _infoRow("Pemakaian", pemakaianText),
                  const SizedBox(height: 8),
                  _infoRow("Harga", hargaText, isPrice: true),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Bukti Pembayaran ──────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Bukti Pembayaran",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 14),
                  proofUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            proofUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                height: 110,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => _noProof(),
                          ),
                        )
                      : _noProof(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Tombol Tolak & Terima ─────────────────────────────
            Row(
              children: [
                // TOLAK — FIXED: sekarang benar-benar panggil rejectBill
                Expanded(
                  child: OutlinedButton(
                    onPressed: isProcessing
                        ? null
                        : () async {
                            final confirmed = await _confirm(
                              context,
                              title: "Tolak Pembayaran?",
                              message:
                                  "Tagihan ini akan dianggap belum terbayar.",
                              confirmText: "Tolak",
                              confirmColor: Colors.red,
                            );
                            if (confirmed == true && context.mounted) {
                              final controller =
                                  context.read<TagihanController>();
                              try {
                                final success =
                                    await controller.rejectBill(bill, token);
                                if (!context.mounted) return;
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text("Pembayaran berhasil ditolak."),
                                      backgroundColor: Colors.orange,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  Navigator.pop(context, 'rejected');
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                color: Colors.red, strokeWidth: 2),
                          )
                        : const Text("Tolak",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                  ),
                ),

                const SizedBox(width: 12),

                // TERIMA
                Expanded(
                  child: ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () async {
                            final confirmed = await _confirm(
                              context,
                              title: "Terima Pembayaran?",
                              message:
                                  "Tagihan akan diverifikasi dan ditandai lunas.",
                              confirmText: "Terima",
                              confirmColor: const Color(0xFF0F52BA),
                            );
                            if (confirmed == true && context.mounted) {
                              final controller =
                                  context.read<TagihanController>();
                              try {
                                final success =
                                    await controller.verifyBill(bill, token);
                                if (!context.mounted) return;
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Berhasil diverifikasi!"),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  Navigator.pop(context, 'verified');
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F52BA),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("Terima",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Widget helpers ──────────────────────────────────────────────────────────

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: child,
      );

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(4)),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
      );

  Widget _infoRow(String label, String value, {bool isPrice = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(value,
              style: TextStyle(
                color: isPrice ? const Color(0xFF0F52BA) : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: isPrice ? 15 : 13,
              )),
        ],
      );

  Widget _noProof() => Container(
        height: 110,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined,
                color: Colors.grey.shade400, size: 34),
            const SizedBox(height: 8),
            Text("Bukti pembayaran belum diunggah",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ],
        ),
      );

  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) =>
      showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Batal")),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(confirmText,
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
}