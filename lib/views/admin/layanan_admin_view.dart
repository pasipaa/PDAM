import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ukl_mobile_uiux/controllers/layanan_controller.dart';
import 'package:ukl_mobile_uiux/views/admin/edit_layanan_view.dart';
import 'package:ukl_mobile_uiux/views/admin/tambah_layanan_view.dart';
import 'package:ukl_mobile_uiux/widgets/admin_bottom_navbar.dart';

class LayananAdminView extends StatefulWidget {
  final String token;
  const LayananAdminView({super.key, required this.token});

  @override
  State<LayananAdminView> createState() => _LayananAdminViewState();
}

class _LayananAdminViewState extends State<LayananAdminView> {
  final searchC = TextEditingController();
  String searchQuery = ""; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LayananController>().getLayanan(widget.token);
    });
  }

  @override
  void dispose() {
    searchC.dispose();
    super.dispose();
  }

  String formatRupiah(dynamic number) {
    if (number == null) return "Rp 0";
    final currencyField = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyField.format(int.parse(number.toString()));
  }

  void _showDeleteBottomSheet(
    BuildContext context,
    LayananController provider,
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
            24,
            32,
            24,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
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
                  child: const Icon(
                    Icons.delete_forever,
                    size: 40,
                    color: Colors.red,
                  ),
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
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(text: "Data anda akan otomatis "),
                      TextSpan(
                        text: "hilang permanen",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0052CC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);

                      bool success = await provider.deleteLayanan(
                        id,
                        widget.token,
                      );

                      if (context.mounted) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Layanan berhasil dihapus"),
                            ),
                          );
                          provider.getLayanan(widget.token);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Gagal menghapus layanan!"),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      "Hapus",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Batal",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildSearchBar() {
    return Padding(
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
                  hintText: "Cari data berdasarkan nama layanan...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            Icon(Icons.tune_rounded, color: Colors.blue.shade600, size: 22),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layananProvider = context.watch<LayananController>();

    final filteredLayanan = layananProvider.layanan.where((element) {
      final name = element['name']?.toString().toLowerCase() ?? '';
      return name.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF4F8FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),

            Expanded(
              child: layananProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredLayanan.isEmpty
                      ? const Center(
                          child: Text(
                            "Tidak ada layanan ditemukan",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => context
                              .read<LayananController>()
                              .getLayanan(widget.token),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                            itemCount: filteredLayanan.length,
                            itemBuilder: (context, index) {
                              final item = filteredLayanan[index];

                              IconData iconLayanan = Icons.home_rounded;
                              if (item['name'].toString().toLowerCase().contains('komersial')) {
                                iconLayanan = Icons.business_rounded;
                              } else if (item['name'].toString().toLowerCase().contains('industri')) {
                                iconLayanan = Icons.precision_manufacturing_rounded;
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xff0066FF),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: Icon(
                                            iconLayanan,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xffEAF9F1),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: const Text(
                                                  "ACTIVE",
                                                  style: TextStyle(
                                                    color: Color(0xff27AE60),
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item['name'] ?? '-',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff2A3238),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit_note_rounded,
                                            color: Colors.black87,
                                            size: 26,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditLayananView(
                                                  dataLayanan: item,
                                                  token: widget.token, layananData: item, 
                                                ),
                                              ),
                                            ).then((value) {
                                              if (context.mounted) {
                                                context
                                                    .read<LayananController>()
                                                    .getLayanan(widget.token);
                                              }
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: Colors.red,
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            _showDeleteBottomSheet(
                                              context,
                                              layananProvider,
                                              item['id'],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "PENGGUNAAN",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          "${item['min_usage'] ?? 0} - ${item['max_usage'] ?? 0} m³",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "HARGA PER M³",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          formatRupiah(item['price']),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff0066FF),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24, thickness: 1),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 60,
                                          height: 24,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                child: CircleAvatar(
                                                  radius: 11,
                                                  backgroundColor: const Color(0xff0066FF).withOpacity(0.2),
                                                ),
                                              ),
                                              Positioned(
                                                left: 12,
                                                child: CircleAvatar(
                                                  radius: 11,
                                                  backgroundColor: const Color(0xff0066FF).withOpacity(0.4),
                                                ),
                                              ),
                                              Positioned(
                                                left: 24,
                                                child: CircleAvatar(
                                                  radius: 11,
                                                  backgroundColor: const Color(0xff0066FF).withOpacity(0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          "${item['total_users'] ?? index * 6 + 13} Pengguna",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
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
        backgroundColor: const Color(0xff0066FF),
        shape: const CircleBorder(),
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TambahLayananView(token: widget.token, dataLayanan: const {}),
            ),
          ).then((value) {
            context.read<LayananController>().getLayanan(widget.token);
          });
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),

      bottomNavigationBar: CustomBottomNavbar(
        token: widget.token,
        currentIndex: 1,
      ),
    );
  }
}