import 'package:flutter/material.dart';
import 'package:ukl_mobile_uiux/controllers/customers/customers_controller.dart';
import 'package:ukl_mobile_uiux/models/customers/customer_tagihan_models.dart';
import 'package:ukl_mobile_uiux/views/customers/detail_baar_view.dart';
import 'package:ukl_mobile_uiux/widgets/cust_bottom_navbar.dart';

class TagihanCustView extends StatefulWidget {
  final String token;

  const TagihanCustView({super.key, required this.token});

  @override
  State<TagihanCustView> createState() => _TagihanCustViewState();
}

class _TagihanCustViewState extends State<TagihanCustView> {
  final CustomerController _controller = CustomerController();
  late Future<List<CustomerBill>> _billFuture;

  @override
  void initState() {
    super.initState();
    _billFuture = _controller.getBillsWithStatus(widget.token);
  }

  String _getIndonesianMonth(int monthNumber) {
    const months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];
    if (monthNumber < 1 || monthNumber > 12) return "Bulan";
    return months[monthNumber - 1];
  }

  Widget _buildStatusButton(String status, CustomerBill item) {
    final lunasStatuses = [
      'lunas',
      'selesai',
      'verified',
      'success',
      'approved',
      'done',
    ];
    final pendingStatuses = [
      'pending',
      'menunggu',
      'proses',
      'waiting',
      'verifying',
      'review',
    ];
    final rejectedStatuses = ['ditolak', 'rejected', 'gagal', 'failed'];
    final belumBayarStatuses = ['belum_bayar', 'unpaid', 'belum bayar'];

    if (lunasStatuses.contains(status)) {
      return OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xff22C55E), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color(0xffF0FDF4),
        ),
        child: const Text(
          "Selesai (Lunas)",
          style: TextStyle(
            color: Color(0xff16A34A),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    } else if (pendingStatuses.contains(status)) {
      return OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xffF59E0B), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color(0xffFFFBEB),
        ),
        child: const Text(
          "Menunggu Verifikasi",
          style: TextStyle(
            color: Color(0xffD97706),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    } else if (rejectedStatuses.contains(status)) {
      return OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xffEF4444), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color(0xffFEF2F2),
        ),
        child: const Text(
          "Pembayaran Ditolak",
          style: TextStyle(
            color: Color(0xffDC2626),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    } else if (belumBayarStatuses.contains(status)) {
      return ElevatedButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailBayarView(
                token: widget.token,
                dynamicStatus: status,
                bill: {
                  "id": item.id.toString(),
                  "periode": "${_getIndonesianMonth(item.month)} ${item.year}",
                  "pemakaian": item.usageValue.toString(),
                  "harga": item.totalPrice.toString(),
                },
              ),
            ),
          );
          // Refresh otomatis setelah balik dari halaman bayar
          if (result == true && mounted) {
            setState(() {
              _billFuture = _controller.getBillsWithStatus(widget.token);
            });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff0A59D1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Bayar Sekarang",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    } else {
      // Fallback status tidak dikenal
      return OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade400, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.grey.shade50,
        ),
        child: Text(
          status,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F8FB),
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            "Riwayat Tagihan",
            style: TextStyle(
              color: Color(0xff1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<CustomerBill>>(
        future: _billFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada data riwayat tagihan.",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final allData = snapshot.data!;

          final data = allData.where((item) {
            final String status = item.status.toLowerCase().trim();

            final pendingStatuses = [
              'pending',
              'menunggu',
              'proses',
              'waiting',
              'verifying',
              'review',
            ];
            final approvedStatuses = [
              'lunas',
              'selesai',
              'verified',
              'success',
              'approved',
              'done',
            ];
            final rejectedStatuses = ['ditolak', 'rejected', 'gagal', 'failed'];
            final belumBayarStatuses = ['belum_bayar', 'unpaid', 'belum bayar'];

            return pendingStatuses.contains(status) ||
                approvedStatuses.contains(status) ||
                rejectedStatuses.contains(status) ||
                belumBayarStatuses.contains(status);
          }).toList();

          if (data.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada riwayat pembayaran yang diproses.",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _billFuture = _controller.getBillsWithStatus(widget.token);
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                final status = item.status.toLowerCase().trim();
                debugPrint(
                  "=== BILL ${item.id} | status: '${item.status}' | trimmed: '$status'",
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100, width: 1),
                  ),
                  child: Column(
                    children: [
                      _buildRowData(
                        "Periode",
                        "${_getIndonesianMonth(item.month)} ${item.year}",
                      ),
                      const SizedBox(height: 12),
                      _buildRowData("Pemakaian", "${item.usageValue} m³"),
                      const SizedBox(height: 12),
                      _buildRowData(
                        "Harga",
                        "Rp ${_formatPrice(item.totalPrice)}",
                        isPrice: true,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: _buildStatusButton(status, item),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: CustomCustomerBottomNavbar(
        token: widget.token,
        currentIndex: 1,
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Widget _buildRowData(String label, String value, {bool isPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xff64748B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isPrice ? 14 : 13,
            color: isPrice ? const Color(0xff0A59D1) : const Color(0xff1E293B),
          ),
        ),
      ],
    );
  }
}
