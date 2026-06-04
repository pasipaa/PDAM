import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukl_mobile_uiux/controllers/tagihan%20controller.dart';
import 'package:ukl_mobile_uiux/views/admin/addTagihan_view.dart';
import 'package:ukl_mobile_uiux/views/admin/detailTagihan_view.dart';
import 'package:ukl_mobile_uiux/views/admin/edit_tagihan_view.dart';
import 'package:ukl_mobile_uiux/widgets/admin_bottom_navbar.dart';

class TagihanView extends StatefulWidget {
  final String token;
  const TagihanView({super.key, required this.token});

  @override
  State<TagihanView> createState() => _TagihanViewState();
}

class _TagihanViewState extends State<TagihanView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (context.mounted) {
        await context.read<TagihanController>().getBills(widget.token);
      }
    });
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

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

  /// Struktur API:
  ///   payments == null              → belum bayar
  ///   payments is Map, verified false → pending (menunggu verifikasi)
  ///   payments is Map, verified true  → lunas
  ///   paid == true (fallback)         → lunas
  String _getBillStatus(Map<String, dynamic> bill) {
    final payments = bill['payments'];

    if (payments is Map<String, dynamic>) {
      final verified = payments['verified'];
      final isVerified = verified == true || verified == 1 || verified == 'true';
      return isVerified ? 'lunas' : 'pending';
    }

    // Fallback: cek field paid / verified_payment langsung di bill
    final isPaid = bill['paid'] == true ||
        bill['paid'] == 1 ||
        bill['paid'] == 'true' ||
        bill['paid'] == '1' ||
        bill['verified_payment'] == true;

    if (isPaid) return 'lunas';

    return 'belum_bayar';
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> _handleDelete(
      BuildContext context, Map<String, dynamic> bill) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Tagihan?",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            "Data tagihan yang sudah lunas ini akan dihapus permanen."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Batal")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final controller = context.read<TagihanController>();
      final billId = bill['id'];

      final success = await controller.deleteBill(billId, widget.token);

      if (!context.mounted) return;

      if (success) {
        await controller.getBills(widget.token);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Tagihan berhasil dihapus."),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal menghapus tagihan. Coba lagi."),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tagihanController = context.watch<TagihanController>();

    final filteredBills = tagihanController.bills.where((bill) {
      final billIdStr = (bill['id'] ?? '').toString().toLowerCase();
      final customerIdStr =
          (bill['customer_id'] ?? '').toString().toLowerCase();
      final customerNameStr =
          (bill['customer']?['name'] ?? '').toString().toLowerCase();
      return billIdStr.contains(_searchQuery) ||
          customerIdStr.contains(_searchQuery) ||
          customerNameStr.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                    hintText: 'Cari pelanggan berdasarkan nama atau ID...',
                    hintStyle:
                        TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    border: InputBorder.none,
                    suffixIcon:
                        const Icon(Icons.tune, color: Colors.blue),
                  ),
                ),
              ),
            ),

            // ── List ───────────────────────────────────────────────
            Expanded(
              child: tagihanController.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredBills.isEmpty
                      ? const Center(
                          child: Text(
                            "Tidak ada data tagihan",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              tagihanController.getBills(widget.token),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: filteredBills.length,
                            itemBuilder: (context, index) {
                              final bill =
                                  filteredBills[index] as Map<String, dynamic>;
                              final billStatus = _getBillStatus(bill);

                              // ── Status badge ──────────────────────
                              final String statusText;
                              final Color statusColor;
                              final Color dotColor;

                              switch (billStatus) {
                                case 'lunas':
                                  statusText = "Lunas";
                                  statusColor = Colors.green.shade600;
                                  dotColor = Colors.green;
                                  break;
                                case 'pending':
                                  statusText = "Menunggu Verifikasi";
                                  statusColor = Colors.amber.shade700;
                                  dotColor = Colors.amber;
                                  break;
                                case 'rejected':
                                  statusText = "Ditolak";
                                  statusColor = Colors.red.shade600;
                                  dotColor = Colors.red;
                                  break;
                                default:
                                  statusText = "Belum Bayar";
                                  statusColor = Colors.red.shade600;
                                  dotColor = Colors.red;
                              }

                              final String customerName =
                                  bill['customer']?['name'] ??
                                      "Pelanggan ${bill['customer_id']}";
                              final String nik =
                                  bill['customer']?['customer_number'] ??
                                      bill['customer']?['nik'] ??
                                      '-';
                              final String tipeLayanan =
                                  bill['service']?['name'] ?? "Umum";
                              final int? monthInt = int.tryParse(
                                  bill['month']?.toString() ?? '');
                              final String periodeText =
                                  "${getNamaBulan(monthInt)} ${bill['year'] ?? ''}";
                              final String pemakaianText =
                                  "${bill['usage_value'] ?? '0'} m³";
                              final String hargaText = formatRupiah(
                                  bill['total_price'] ??
                                      bill['amount'] ??
                                      0);
                              final bool isActive =
                                  bill['customer']?['status'] == 'active' ||
                                      bill['customer']?['is_active'] == true;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // ── Header ────────────────────────
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor:
                                              Colors.grey.shade200,
                                          child: const Icon(Icons.person,
                                              color: Colors.grey, size: 26),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                customerName,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "NIK : $nik",
                                                style: TextStyle(
                                                    color:
                                                        Colors.grey.shade500,
                                                    fontSize: 11),
                                              ),
                                              const SizedBox(height: 6),
                                              Wrap(
                                                spacing: 6,
                                                children: [
                                                  _badge(tipeLayanan,
                                                      Colors.blue),
                                                  _badge(
                                                    isActive
                                                        ? "Aktif"
                                                        : "Nonaktif",
                                                    isActive
                                                        ? Colors.green
                                                        : Colors.red,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Dot status + label
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              width: 11,
                                              height: 11,
                                              decoration: BoxDecoration(
                                                color: dotColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              statusText,
                                              style: TextStyle(
                                                color: statusColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),
                                    const Divider(height: 1, thickness: 0.5),
                                    const SizedBox(height: 12),

                                    // ── Detail rows ──────────────────
                                    _infoRow("Periode", periodeText),
                                    const SizedBox(height: 6),
                                    _infoRow("Pemakaian", pemakaianText),
                                    const SizedBox(height: 6),
                                    _infoRow("Harga", hargaText,
                                        isPrice: true),

                                    const SizedBox(height: 14),

                                    // ── Action buttons ───────────────
                                    Row(
                                      children: [
                                        // Tombol EDIT (selalu ada)
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      EditTagihanView(
                                                    token: widget.token,
                                                    billData: bill,
                                                  ),
                                                ),
                                              ).then((_) {
                                                if (context.mounted) {
                                                  context
                                                      .read<TagihanController>()
                                                      .getBills(widget.token);
                                                }
                                              });
                                            },
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                  color: Color(0xFF0F52BA)),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 11),
                                            ),
                                            child: const Text(
                                              "Edit",
                                              style: TextStyle(
                                                  color: Color(0xFF0F52BA),
                                                  fontWeight:
                                                      FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),

                                        // Tombol kanan berdasarkan status
                                        Expanded(
                                          child: billStatus == 'lunas'
                                              // ── Lunas → Hapus ──
                                              ? ElevatedButton(
                                                  onPressed: () =>
                                                      _handleDelete(
                                                          context, bill),
                                                  style: ElevatedButton
                                                      .styleFrom(
                                                    backgroundColor:
                                                        Colors.red.shade600,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8)),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 11),
                                                    elevation: 0,
                                                  ),
                                                  child: const Text(
                                                    "Hapus",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                )
                                              : billStatus == 'pending'
                                                  // ── Pending → Verifikasi ──
                                                  ? ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (_) =>
                                                                DetailTagihanView(
                                                              token:
                                                                  widget.token,
                                                              bill: bill,
                                                            ),
                                                          ),
                                                        ).then((result) {
                                                          if ((result == 'verified' ||
                                                                  result == 'rejected') &&
                                                              context.mounted) {
                                                            context
                                                                .read<TagihanController>()
                                                                .getBills(widget.token);
                                                          }
                                                        });
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            const Color(
                                                                0xFF0F52BA),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8)),
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            vertical: 11),
                                                        elevation: 0,
                                                      ),
                                                      child: const Text(
                                                        "Verifikasi",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    )
                                                  // ── Belum bayar / rejected → disabled ──
                                                  : ElevatedButton(
                                                      onPressed: null,
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.grey
                                                                .shade300,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8)),
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            vertical: 11),
                                                        elevation: 0,
                                                      ),
                                                      child: Text(
                                                        billStatus ==
                                                                'rejected'
                                                            ? "Ditolak"
                                                            : "Belum Bayar",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
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
            MaterialPageRoute(
                builder: (_) => TambahTagihanView(token: widget.token)),
          ).then((result) {
            if (result == true && context.mounted) {
              context.read<TagihanController>().getBills(widget.token);
            }
          });
        },
        backgroundColor: Colors.blueAccent,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      bottomNavigationBar:
          CustomBottomNavbar(token: widget.token, currentIndex: 3),
    );
  }

  // ── Widget helpers ─────────────────────────────────────────────────────────

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
          Text(
            value,
            style: TextStyle(
              color: isPrice ? const Color(0xFF0F52BA) : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: isPrice ? 15 : 13,
            ),
          ),
        ],
      );
}