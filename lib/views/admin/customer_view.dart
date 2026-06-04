import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukl_mobile_uiux/controllers/customer_controller.dart';
import 'package:ukl_mobile_uiux/views/admin/tambah_customer_view.dart';
import 'package:ukl_mobile_uiux/views/admin/edit_customer_view.dart';
import 'package:ukl_mobile_uiux/widgets/admin_bottom_navbar.dart';

class CustomerView extends StatefulWidget {
  final String token;

  const CustomerView({super.key, required this.token});

  @override
  State<CustomerView> createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView> {
  late CustomerAdminController _customerController;
  String activeFilter = "Semua";
  final searchC = TextEditingController();
  String _activeToken = "";

  @override
  void initState() {
    super.initState();
    _activeToken = widget.token;
    _customerController =
        Provider.of<CustomerAdminController>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataSafely();
    });

    searchC.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadDataSafely() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');

    if (savedToken != null && savedToken.isNotEmpty) {
      if (mounted) setState(() => _activeToken = savedToken);
    }

    _customerController.getCustomers(_activeToken);
  }

  @override
  void dispose() {
    searchC.dispose();
    super.dispose();
  }

  Color _getServiceColor(String serviceName) {
    final name = serviceName.toLowerCase();
    if (name.contains('rumah') || name.contains('tetap')) {
      return const Color(0xff0066FF);
    }
    if (name.contains('komersial') || name.contains('bisnis')) {
      return Colors.orange;
    }
    if (name.contains('industri')) return Colors.purple;
    return Colors.teal;
  }

  // ─── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── SEARCH BAR ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.blueGrey.shade100.withOpacity(0.6),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey.shade500, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: searchC,
                        decoration: InputDecoration(
                          hintText: "Cari pelanggan berdasarkan nama...",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    Icon(Icons.tune_rounded,
                        color: Colors.blue.shade600, size: 22),
                  ],
                ),
              ),
            ),

            // ── FILTER CHIPS ─────────────────────────────────────────────────
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: ["Semua", "Rumah Tangga", "Komersial", "Industri"]
                    .map((filter) {
                  final isSelected = activeFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: const Color(0xff0066FF),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey.shade300,
                        ),
                      ),
                      onSelected: (_) {
                        if (mounted) setState(() => activeFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // ── STAT CARDS ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Consumer<CustomerAdminController>(
                builder: (context, controller, child) {
                  // Hitung pelanggan baru hari ini (berdasarkan createdAt jika tersedia)
                  final today = DateTime.now();
                  final newToday = controller.customers.where((c) {
                    if (c.createdAt == null) return false;
                    final d = c.createdAt!;
                    return d.year == today.year &&
                        d.month == today.month &&
                        d.day == today.day;
                  }).length;

                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: "Total Pelanggan Aktif",
                          value: controller.customers.length.toString(),
                          icon: Icons.people_alt_rounded,
                          color: const Color(0xff0066FF),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildStatCard(
                          title: "Pelanggan Baru Hari Ini",
                          value: "+$newToday",
                          icon: Icons.person_add_alt_1_rounded,
                          color: const Color(0xff00B365),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── CUSTOMER LIST ────────────────────────────────────────────────
            Expanded(
              child: Consumer<CustomerAdminController>(
                builder: (context, controller, child) {
                  if (controller.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xff0066FF)),
                      ),
                    );
                  }

                  final filteredList =
                      controller.customers.where((item) {
                    final serviceName =
                        (item.service?.name ?? "Layanan Tetap").toLowerCase();
                    final nameMatches = item.name
                        .toLowerCase()
                        .contains(searchC.text.toLowerCase());

                    bool filterMatches = activeFilter == "Semua";
                    if (activeFilter == "Rumah Tangga") {
                      filterMatches = serviceName.contains("rumah") ||
                          serviceName.contains("tetap");
                    } else if (activeFilter != "Semua") {
                      filterMatches =
                          serviceName.contains(activeFilter.toLowerCase());
                    }
                    return nameMatches && filterMatches;
                  }).toList();

                  if (filteredList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 52, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            "Belum ada data customer",
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _loadDataSafely,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final customer = filteredList[index];
                        final serviceName =
                            customer.service?.name ?? "Layanan Tetap";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                    const Color(0xff0066FF).withOpacity(0.1),
                                child: Text(
                                  customer.name.isNotEmpty
                                      ? customer.name[0].toUpperCase()
                                      : "?",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff0066FF),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff0A2540),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "@${customer.username ?? '-'}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade400,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "NIK : ${customer.customerNumber}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                _getServiceColor(serviceName),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            serviceName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                const Color(0xffE6F9F0),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            "Aktif",
                                            style: TextStyle(
                                              color: Color(0xff00B365),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Action buttons
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_note_rounded,
                                      color: Colors.black87,
                                      size: 26,
                                    ),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(4),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EditCustomerView(
                                            token: _activeToken,
                                            customer: customer,
                                          ),
                                        ),
                                      ).then((_) {
                                        if (mounted) {
                                          _customerController
                                              .getCustomers(_activeToken);
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_forever_rounded,
                                      color: Colors.redAccent,
                                      size: 24,
                                    ),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(4),
                                    onPressed: () => _showDeleteBottomSheet(
                                        context, controller, customer.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ── FAB ────────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff0066FF),
        shape: const CircleBorder(),
        elevation: 4,
        child:
            const Icon(Icons.group_add_rounded, color: Colors.white, size: 26),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TambahCustomerView(token: _activeToken),
            ),
          ).then((_) {
            if (mounted) {
              _customerController.getCustomers(_activeToken);
            }
          });
        },
      ),

      bottomNavigationBar:
          CustomBottomNavbar(token: _activeToken, currentIndex: 2),
    );
  }

  // ─── STAT CARD WIDGET ────────────────────────────────────────────────────────
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey.shade50, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Icon(icon, color: color.withOpacity(0.2), size: 28),
            ],
          ),
        ],
      ),
    );
  }

  // ─── DELETE BOTTOM SHEET ─────────────────────────────────────────────────────
  void _showDeleteBottomSheet(
    BuildContext context,
    CustomerAdminController provider,
    int id,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              24, 32, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_forever_rounded,
                      color: Colors.red, size: 40),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Anda yakin ingin menghapus?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(text: "Data customer akan otomatis "),
                      TextSpan(
                        text: "hilang permanen",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                          text:
                              " dan tidak dapat digunakan untuk login kembali."),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      // Simpan messenger & token SEBELUM pop agar context tidak invalid
                      final messenger = ScaffoldMessenger.of(context);
                      final tokenSnapshot = _activeToken;
                      Navigator.pop(context);

                      // deleteCustomer sekarang return Map agar bisa baca pesan error dari server
                      final result = await provider.deleteCustomer(id, tokenSnapshot);
                      final success = result["success"] == true;
                      final msg = result["message"] as String? ??
                          (success ? "Customer berhasil dihapus" : "Gagal menghapus customer!");

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(success ? "Customer berhasil dihapus" : msg),
                          backgroundColor: success ? Colors.green : Colors.red,
                          duration: Duration(seconds: success ? 2 : 4),
                        ),
                      );
                      if (success) {
                        provider.getCustomers(tokenSnapshot);
                      }
                    },
                    child: const Text(
                      "Hapus",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Colors.grey.shade300, width: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Batal",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}