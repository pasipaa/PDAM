import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukl_mobile_uiux/controllers/tagihan%20controller.dart';
import 'package:ukl_mobile_uiux/views/admin/addTagihan_view.dart';
import 'package:ukl_mobile_uiux/views/admin/edit_tagihan_view.dart';
import 'package:ukl_mobile_uiux/widgets/admin_bottom_navbar.dart';

class TagihanView extends StatefulWidget {
  final String token;

  const TagihanView({
    super.key,
    required this.token,
  });

  @override
  State<TagihanView> createState() => _TagihanViewState();
}

class _TagihanViewState extends State<TagihanView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TagihanController>().getBills(widget.token);
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> handleVerify(BuildContext context, Map<String, dynamic> bill) async {
    final controller = context.read<TagihanController>();
    bool success = await controller.verifyBill(bill, widget.token);

    if (!context.mounted) return;

    if (success) {
      await controller.getBills(widget.token);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Berhasil diverifikasi! Status menjadi Lunas."), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal verifikasi! Bukti belum lengkap."), backgroundColor: Colors.red),
      );
    }
  }

  void _showDeleteBottomSheet(BuildContext context, TagihanController provider, int id) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 32, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
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
                  child: Image.asset("assets/delete.png", height: 40, width: 40, errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 40);
                  }),
                ),
                const SizedBox(height: 20),
                const Text("Anda yakin ingin menghapus?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(text: "Data anda akan otomatis "),
                      TextSpan(text: "hilang permanen", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red, width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batal", style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff0052CC),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          bool success = await provider.deleteBill(id, widget.token);
                          
                          if (context.mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Data tagihan berhasil dihapus"), backgroundColor: Colors.orange)
                              );
                              provider.getBills(widget.token);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Gagal menghapus data tagihan!"), backgroundColor: Colors.red)
                              );
                            }
                          }
                        },
                        child: const Text("Hapus", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String formatRupiah(dynamic value) {
    final number = int.tryParse(value.toString()) ?? 0;
    String result = number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return "Rp $result";
  }

  String getNamaBulan(int month) {
    const bulan = ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"];
    if (month >= 1 && month <= 12) return bulan[month - 1];
    return month.toString();
  }

  @override
  Widget build(BuildContext context) {
    final tagihanController = context.watch<TagihanController>();

    final filteredBills = tagihanController.bills.where((bill) {
      final String rawStatus = (bill['status'] ?? 'belumbayar').toString().toLowerCase().trim();
      
      if (rawStatus == 'belumbayar' || rawStatus == 'unpaid') {
        return false;
      }

      final billIdStr = (bill['id'] ?? '').toString().toLowerCase();
      final customerIdStr = (bill['customer_id'] ?? '').toString().toLowerCase();
      final customerNameStr = (bill['customer'] != null && bill['customer']['name'] != null)
          ? bill['customer']['name'].toString().toLowerCase()
          : '';

      return billIdStr.contains(_searchQuery) ||
             customerIdStr.contains(_searchQuery) ||
             customerNameStr.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Colors.grey.shade500),
                    hintText: 'Cari verifikasi berdasarkan nama...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    border: InputBorder.none,
                    suffixIcon: const Icon(Icons.tune, color: Colors.blue),
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: tagihanController.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredBills.isEmpty
                      ? const Center(
                          child: Text("Tidak ada antrean pembayaran masuk", style: TextStyle(color: Colors.grey, fontSize: 15)),
                        )
                      : RefreshIndicator(
                          onRefresh: () => tagihanController.getBills(widget.token),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredBills.length,
                            itemBuilder: (context, index) {
                              final bill = filteredBills[index];
                              final int billId = int.tryParse(bill['id'].toString()) ?? 0;
                              final bool isProcessing = tagihanController.processingBillIds.contains(billId);
                              
                              final String rawStatus = (bill['status'] ?? '').toString().toLowerCase().trim();
                              
                              final bool isVerified = ['lunas', 'selesai', 'paid', 'verified', 'success'].contains(rawStatus);

                              String statusText = "Pending";
                              Color statusColor = Colors.amber.shade700;

                              if (isVerified) {
                                statusText = "Selesai (Lunas)";
                                statusColor = Colors.green;
                              }

                              String customerName = (bill['customer'] != null && bill['customer']['name'] != null)
                                  ? bill['customer']['name']
                                  : "Pelanggan ${bill['customer_id']}";
                              
                              String tipeLayanan = (bill['service'] != null) ? bill['service']['name'] : "Umum";
                              String periodeText = "${getNamaBulan(int.tryParse(bill['month'].toString()) ?? 1)} ${bill['year'] ?? ''}";
                              String pemakaianText = "${bill['usage_value'] ?? '0'} m³";
                              String hargaText = formatRupiah(bill['amount'] ?? 0);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundColor: Colors.grey.shade300,
                                          child: const Icon(Icons.face, color: Colors.grey),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                customerName,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'No. Meter : ${bill['measurement_number'] ?? '-'}',
                                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      tipeLayanan,
                                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: statusColor,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      statusText,
                                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: statusColor,
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 16),
                                    
                                    _buildInfoRow('Periode', periodeText),
                                    const SizedBox(height: 6),
                                    _buildInfoRow('Pemakaian', pemakaianText),
                                    const SizedBox(height: 6),
                                    _buildInfoRow('Harga', hargaText, isPrice: true),
                                    
                                    const SizedBox(height: 16),
                                    
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: isVerified ? null : () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => EditTagihanView(
                                                    token: widget.token,
                                                    billData: bill,
                                                  ),
                                                ),
                                              );
                                            },
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(color: isVerified ? Colors.grey.shade300 : const Color(0xFF0F52BA)),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                            child: Text('Edit', style: TextStyle(color: isVerified ? Colors.grey : const Color(0xFF0F52BA), fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: isProcessing
                                                ? null
                                                : isVerified
                                                    ? () => _showDeleteBottomSheet(context, tagihanController, billId)
                                                    : () => handleVerify(context, bill),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isVerified ? const Color(0xFFE50000) : const Color(0xFF0F52BA),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              elevation: 0,
                                            ),
                                            child: isProcessing
                                                ? const SizedBox(
                                                    height: 18,
                                                    width: 18,
                                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                                  )
                                                : Text(
                                                    isVerified ? 'Hapus Riwayat' : 'Verifikasi Pembayaran',
                                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTagihanView(token: widget.token)),
          );
        },
        backgroundColor: Colors.blueAccent,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      bottomNavigationBar: CustomBottomNavbar(token: widget.token, currentIndex: 3),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: isPrice ? Colors.blue : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: isPrice ? 15 : 13,
          ),
        ),
      ],
    );
  }
}