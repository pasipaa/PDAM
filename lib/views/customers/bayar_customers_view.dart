import 'package:flutter/material.dart';
import 'package:ukl_mobile_uiux/controllers/customers/customers_controller.dart';
import 'package:ukl_mobile_uiux/models/customers/customer_tagihan_models.dart';
import 'package:ukl_mobile_uiux/views/customers/detail_baar_view.dart';
import 'package:ukl_mobile_uiux/widgets/cust_bottom_navbar.dart';

class BayarCustView extends StatefulWidget {
  final String token;
  const BayarCustView({super.key, required this.token});

  @override
  State<BayarCustView> createState() => _BayarCustViewState();
}

class _BayarCustViewState extends State<BayarCustView> {
  final CustomerController _controller = CustomerController();
  late Future<List<CustomerBill>> _billFuture;

  @override
  void initState() {
    super.initState();
    // ✅ Fix 1: pakai getBillsWithStatus bukan getMyBills
    _billFuture = _controller.getBillsWithStatus(widget.token);
  }

  String _getIndonesianMonth(int monthNumber) {
    const months = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    if (monthNumber < 1 || monthNumber > 12) return "Bulan";
    return months[monthNumber - 1];
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F8FB),
      appBar: AppBar(
        title: const Text(
          "Tagihan Saya",
          style: TextStyle(
              color: Color(0xff1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<CustomerBill>>(
        future: _billFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      "Gagal memuat data tagihan.\nCoba refresh halaman.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => setState(() {
                        _billFuture = _controller.getBillsWithStatus(widget.token);
                      }),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Coba Lagi"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0A59D1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final semua = snapshot.data ?? [];

          // ✅ Fix 2: halaman Bayar HANYA tampilkan yang belum_bayar saja
          // pending/verified/rejected sudah pindah ke halaman Riwayat Tagihan
          final belumBayarStatuses = ['belum_bayar', 'unpaid', 'belum bayar'];
          final data = semua.where((item) {
            final s = item.status.toLowerCase().trim();
            return belumBayarStatuses.contains(s);
          }).toList();

          if (data.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xffE6F9F0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_rounded,
                          color: Color(0xff00B365), size: 48),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Semua Tagihan Lunas!",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Color(0xff0A2540)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Tidak ada tagihan yang perlu dibayar saat ini.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                // ✅ Fix 3: refresh juga pakai getBillsWithStatus
                _billFuture = _controller.getBillsWithStatus(widget.token);
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge status "Belum Dibayar"
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: Colors.red.shade200),
                        ),
                        child: Text(
                          "Belum Dibayar",
                          style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),

                      _buildRowData(
                        "Periode",
                        "${_getIndonesianMonth(item.month)} ${item.year}",
                      ),
                      const SizedBox(height: 10),
                      _buildRowData("Pemakaian", "${item.usageValue} m³"),
                      const SizedBox(height: 10),
                      _buildRowData(
                        "Harga",
                        "Rp ${_formatPrice(item.totalPrice)}",
                        isPrice: true,
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            final Map<String, dynamic> billData = {
                              "id": item.id.toString(),
                              "periode":
                                  "${_getIndonesianMonth(item.month)} ${item.year}",
                              "no_meteran": item.measurementNumber,
                              "pemakaian": item.usageValue.toString(),
                              "harga": item.totalPrice.toString(),
                            };

                            final bool? isUploaded = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailBayarView(
                                  bill: billData,
                                  token: widget.token,
                                  dynamicStatus: item.status,
                                ),
                              ),
                            );

                            // ✅ Fix 4: refresh pakai getBillsWithStatus
                            // tagihan yang sudah upload otomatis hilang dari list ini
                            if (isUploaded == true && mounted) {
                              setState(() {
                                _billFuture =
                                    _controller.getBillsWithStatus(widget.token);
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0A59D1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Bayar Sekarang",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                          ),
                        ),
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
        currentIndex: 2,
      ),
    );
  }

  Widget _buildRowData(String label, String value, {bool isPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xff71717A),
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isPrice
                    ? const Color(0xff0A59D1)
                    : const Color(0xff18181B))),
      ],
    );
  }
}