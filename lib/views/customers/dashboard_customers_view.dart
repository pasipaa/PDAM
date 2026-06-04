import 'package:flutter/material.dart';
import 'package:ukl_mobile_uiux/controllers/customers/customers_controller.dart';
import 'package:ukl_mobile_uiux/models/customers/customer_profile_models.dart';
import 'package:ukl_mobile_uiux/models/customers/customer_tagihan_models.dart';
import 'package:ukl_mobile_uiux/widgets/cust_bottom_navbar.dart';

class DashboardCustomerView extends StatefulWidget {
  final String token;
  const DashboardCustomerView({super.key, required this.token});

  @override
  State<DashboardCustomerView> createState() => _DashboardCustomerViewState();
}

class _DashboardCustomerViewState extends State<DashboardCustomerView> {
  final CustomerController _controller = CustomerController();

  late Future<CustomerProfile?> _profileFuture;
  late Future<List<CustomerBill>> _billsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // FIX: hapus didChangeDependencies — itu bikin double/triple fetch setiap rebuild
  // initState sudah cukup untuk load pertama kali

  void _refreshData() {
    setState(() {
      _profileFuture = _controller.getMyProfile(widget.token);
      // FIX: pakai getBillsWithStatus bukan getMyBills
      // getMyBills tidak merge dengan payments, jadi status selalu 'belum_bayar'
      _billsFuture = _controller.getBillsWithStatus(widget.token);
    });
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
      body: SafeArea(
        child: FutureBuilder<CustomerProfile?>(
          future: _profileFuture,
          builder: (context, profileSnapshot) {
            final profileName = profileSnapshot.data?.name ?? "Pelanggan";

            return FutureBuilder<List<CustomerBill>>(
              future: _billsFuture,
              builder: (context, billsSnapshot) {
                final apiBills = billsSnapshot.data ?? [];

                // FIX: filter unpaid hanya yang belum_bayar
                // 'pending' = sudah upload bukti, lagi nunggu verif → bukan "belum bayar"
                // 'verified' = sudah lunas
                final unpaidBills = apiBills.where((b) {
                  final s = b.status.toLowerCase().trim();
                  return s == 'belum_bayar' || s == 'unpaid' || s == 'belum bayar';
                }).toList();

                return RefreshIndicator(
                  onRefresh: () async => _refreshData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            radius: 25,
                            backgroundColor: Color(0xffB4D4FF),
                            child: Icon(Icons.person, color: Color(0xff0A59D1)),
                          ),
                          title: Text(
                            profileName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xff1E293B)),
                          ),
                          subtitle: Text("Welcome back, $profileName",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                        ),
                        const SizedBox(height: 25),

                        _buildContainerCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Tagihan Belum Dibayar",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff0F172A))),
                                  if (unpaidBills.isNotEmpty)
                                    Container(
                                        width: 14,
                                        height: 14,
                                        decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text("${unpaidBills.length}",
                                      style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff0A59D1))),
                                  const SizedBox(width: 6),
                                  const Text("Tagihan Tertunda",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14)),
                                ],
                              ),
                              const Divider(
                                  height: 30,
                                  color: Color(0xffF1F5F9),
                                  thickness: 1.5),

                              if (billsSnapshot.connectionState ==
                                  ConnectionState.waiting)
                                const Center(
                                    child: CircularProgressIndicator())
                              else if (unpaidBills.isEmpty)
                                const Text(
                                    "Lunas 🎉 Semua tagihan Anda sudah terbayar.",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 14))
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  itemCount: unpaidBills.length > 2
                                      ? 2
                                      : unpaidBills.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final bill = unpaidBills[index];
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            "${_getIndonesianMonth(bill.month)} ${bill.year} Bill",
                                            style: const TextStyle(
                                                color: Color(0xff64748B),
                                                fontSize: 14)),
                                        Text(
                                            "Rp ${_formatPrice(bill.totalPrice)}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff1E293B),
                                                fontSize: 14)),
                                      ],
                                    );
                                  },
                                ),
                              const SizedBox(height: 25),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: unpaidBills.isEmpty ? null : () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff0A59D1),
                                    disabledBackgroundColor:
                                        Colors.grey.shade300,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  child: Text("Pay Now",
                                      style: TextStyle(
                                          color: unpaidBills.isEmpty
                                              ? Colors.grey.shade500
                                              : Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildContainerCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Analisis Penggunaan",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff0F172A))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: const Color(0xffEAF2FF),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: const Text("Tahun Ini",
                                        style: TextStyle(
                                            color: Color(0xff0A59D1),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _barChartRod("Jan", 100, false),
                                  _barChartRod("Feb", 80, false),
                                  _barChartRod("Mar", 100, false),
                                  _barChartRod("Apr", 75, true),
                                  _barChartRod("Mei", 8, false),
                                  _barChartRod("Jun", 8, false),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: CustomCustomerBottomNavbar(
        token: widget.token,
        currentIndex: 0,
      ),
    );
  }

  Widget _barChartRod(String label, double heightValue, bool isSelected) {
    return Column(
      children: [
        Container(
          height: heightValue,
          width: 28,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xff0A59D1)
                : const Color(0xff1A61CC).withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? const Color(0xff0A59D1)
                    : const Color(0xff64748B))),
      ],
    );
  }

  Widget _buildContainerCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              spreadRadius: 2,
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }
}